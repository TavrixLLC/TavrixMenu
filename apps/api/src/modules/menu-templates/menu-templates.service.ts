import { Injectable } from '@nestjs/common';
import { getMenuTemplateCatalog } from '@tavrix-menu/menu-templates';

@Injectable()
export class MenuTemplatesService {
  getCatalog() {
    return {
      templates: getMenuTemplateCatalog()
    };
  }
}
