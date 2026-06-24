export default function LoadingMenuPage() {
  return (
    <main
      className="waflo-menu waflo-template-waflo-warm"
      data-template="waflo-warm"
      data-business-slug="loading"
      data-component="public-menu"
      data-state="loading"
      data-dir="ltr"
      data-loyalty-enabled="false"
      lang="en"
      dir="ltr"
    >
      <section className="waflo-menu__shell" data-slot="merchant-shell" data-component="menu-shell">
        <header className="waflo-menu__hero" data-slot="merchant-hero" data-component="merchant-header" data-state="loading">
          <div
            className="waflo-menu__cover"
            data-slot="merchant-cover"
            data-component="merchant-media"
            data-state="loading"
            data-has-image="false"
          >
            <span className="waflo-menu__skeleton" />
          </div>
          <section className="waflo-menu__identity" data-slot="merchant-identity" data-component="merchant-identity">
            <div
              className="waflo-menu__logo"
              data-slot="merchant-logo"
              data-component="merchant-media"
              data-state="loading"
              data-has-image="false"
            >
              <span className="waflo-menu__skeleton" />
            </div>
            <div className="waflo-menu__identity-copy" data-slot="merchant-copy">
              <span className="waflo-menu__skeleton" style={{ width: '7rem' }} />
              <span className="waflo-menu__skeleton" style={{ width: '14rem', height: '2.4rem', marginTop: '0.7rem' }} />
              <span className="waflo-menu__skeleton" style={{ width: '10rem', marginTop: '0.7rem' }} />
            </div>
          </section>
        </header>

        <section className="waflo-menu__body" data-slot="menu-body" data-component="menu-body" data-state="loading">
          {[0, 1, 2].map((item) => (
            <div key={item} className="waflo-menu__skeleton-card" data-slot="skeleton-state" data-component="menu-state" data-state="loading">
              <span className="waflo-menu__skeleton" style={{ aspectRatio: '1', height: 'auto' }} />
              <span>
                <span className="waflo-menu__skeleton" style={{ width: '65%' }} />
                <span className="waflo-menu__skeleton" style={{ width: '90%', marginTop: '0.7rem' }} />
                <span className="waflo-menu__skeleton" style={{ width: '7rem', marginTop: '0.9rem' }} />
              </span>
            </div>
          ))}
        </section>
      </section>
    </main>
  );
}
