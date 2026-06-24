import { PlaceholderImage } from '../../../components/PlaceholderImage';

export default function LoadingMenuPage() {
  return (
    <main className="min-h-screen bg-cream pb-10">
      <section className="mx-auto w-full max-w-5xl px-4 pt-4">
        <PlaceholderImage label="Loading cover" className="h-44 w-full rounded-xl sm:h-64" />
        <div className="-mt-9 flex items-end gap-4 px-3">
          <PlaceholderImage label="Logo" className="h-20 w-20 shrink-0 rounded-xl bg-white shadow-sm" />
          <div className="pb-1">
            <div className="h-4 w-24 rounded bg-[#F1E2D6]" />
            <div className="mt-3 h-8 w-48 rounded bg-[#F1E2D6]" />
            <div className="mt-2 h-4 w-32 rounded bg-[#F1E2D6]" />
          </div>
        </div>
      </section>
      <section className="mx-auto mt-8 grid w-full max-w-5xl gap-3 px-4">
        {[0, 1, 2].map((item) => (
          <div key={item} className="grid grid-cols-[104px_1fr] gap-4 rounded-xl border border-borderSoft bg-white p-3 shadow-sm">
            <div className="aspect-square rounded-lg bg-[#FFF0EA]" />
            <div>
              <div className="h-5 w-40 rounded bg-[#F1E2D6]" />
              <div className="mt-3 h-4 w-full max-w-sm rounded bg-[#FFF0EA]" />
              <div className="mt-4 h-6 w-24 rounded-full bg-[#FFF0EA]" />
            </div>
          </div>
        ))}
      </section>
    </main>
  );
}
