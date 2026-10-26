import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { ALL_PAGES_EXCLUDED_ROUTES } from "discourse/components/welcome-banner";
import { eq } from "discourse/truth-helpers";
import HorizontalOverflowNav from "discourse/ui-kit/d-horizontal-overflow-nav";
import categoryLink from "discourse/ui-kit/helpers/d-category-link";

export default class CustomCategoriesNavbar extends Component {
  @service site;
  @service router;

  @tracked activeCategoryId = null;

  constructor() {
    super(...arguments);
    this.setActiveCategory();
    this.router.on("routeDidChange", this, this.setActiveCategory);
  }

  willDestroy() {
    super.willDestroy(...arguments);
    this.router.off("routeDidChange", this, this.setActiveCategory);
  }

  get visibleCategories() {
    const selectedIds = String(settings.categories_to_show || "")
      .split("|")
      .filter(Boolean)
      .map(Number);

    if (!selectedIds.length) {
      return this.site.categories.filter(
        (category) => !category.parentCategory
      );
    }

    const visibleById = new Map(
      this.site.categories.map((category) => [category.id, category])
    );
    return [...new Set(selectedIds)]
      .map((id) => visibleById.get(id))
      .filter(Boolean);
  }

  get shouldRender() {
    const route = this.router.currentRouteName;

    if (!route || !this.visibleCategories.length) {
      return false;
    }

    if (route.startsWith("admin")) {
      return false;
    }

    const hiddenRoutes = [
      ...ALL_PAGES_EXCLUDED_ROUTES,
      "email-login",
      "discovery.login-required",
      "user",
      "chat",
    ];

    return !hiddenRoutes.some(
      (name) => route === name || route.startsWith(`${name}.`)
    );
  }

  setActiveCategory() {
    const currentRoute = this.router.currentRoute;

    let activeCategory = currentRoute?.attributes?.category;
    const visibleIds = new Set(
      this.visibleCategories.map((category) => category.id)
    );

    while (activeCategory && !visibleIds.has(activeCategory.id)) {
      activeCategory = activeCategory.parentCategory;
    }

    this.activeCategoryId = activeCategory?.id ?? null;

    if (this.activeCategoryId !== null) {
      document
        .querySelector(
          `.custom-categories-navbar li[data-category-id="${this.activeCategoryId}"] a`
        )
        ?.scrollIntoView({ block: "nearest", inline: "center" });
    }
  }

  <template>
    {{#if this.shouldRender}}
      <div class="wrap custom-categories-navbar">
        <HorizontalOverflowNav>
          {{#each this.visibleCategories key="id" as |sc|}}
            <li data-category-id={{sc.id}}>
              {{categoryLink
                sc
                extraClasses=(if (eq this.activeCategoryId sc.id) "active")
              }}
            </li>
          {{/each}}
        </HorizontalOverflowNav>
      </div>
    {{/if}}
  </template>
}
