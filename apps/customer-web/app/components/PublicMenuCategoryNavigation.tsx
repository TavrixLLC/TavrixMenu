'use client';

import { useState } from 'react';
import { getCategoryName, isRtlLanguage } from '../lib/menu-format';
import type { PublicMenuCategory } from '../lib/public-menu';

type PublicMenuCategoryNavigationProps = {
  categories: PublicMenuCategory[];
  language: string | null;
};

function getCategoryAnchor(category: PublicMenuCategory) {
  return `category-${category.id}`;
}

export function PublicMenuCategoryNavigation({
  categories,
  language
}: PublicMenuCategoryNavigationProps) {
  const [activeCategoryId, setActiveCategoryId] = useState(
    categories[0]?.id ?? null
  );

  if (categories.length === 0) {
    return null;
  }

  const direction = isRtlLanguage(language) ? 'rtl' : 'ltr';

  return (
    <nav
      className="waflo-menu__category-nav"
      data-slot="category-navigation"
      data-component="category-navigation"
      data-state={activeCategoryId ? 'has-current' : 'idle'}
      aria-label="Menu categories"
    >
      <ol className="waflo-menu__category-list" data-slot="category-navigation-list">
        {categories.map((category) => {
          const isCurrent = category.id === activeCategoryId;

          return (
            <li key={category.id} data-component="category-navigation-item" data-category-id={category.id}>
              <a
                className="waflo-menu__category-link"
                data-slot="category-link"
                data-component="category-link"
                data-category-id={category.id}
                data-state={isCurrent ? 'current' : 'idle'}
                aria-current={isCurrent ? 'location' : undefined}
                href={`#${getCategoryAnchor(category)}`}
                dir={direction}
                onClick={() => setActiveCategoryId(category.id)}
              >
                {getCategoryName(category, language)}
              </a>
            </li>
          );
        })}
      </ol>
    </nav>
  );
}
