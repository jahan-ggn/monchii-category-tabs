import { apiInitializer } from "discourse/lib/api";
// eslint-disable-next-line discourse/relative-import-extensions
import CustomCategoriesNavbar from "../components/custom-categories-navbar";

export default apiInitializer((api) => {
  api.renderInOutlet("after-header", CustomCategoriesNavbar);
});
