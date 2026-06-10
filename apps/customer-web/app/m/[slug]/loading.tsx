import { PlaceholderImage } from '../../components/PlaceholderImage';

export default function LoadingMenuPage() {
  return (
    <main className="min-h-screen bg-[#fbf7ef] pb-10">
      <section className="mx-auto w-full max-w-4xl px-4 pt-4">
        <PlaceholderImage label="Loading menu" className="h-44 w-full rounded-lg sm:h-56" />
        <div className="-mt-8 flex items-end gap-4 px-3">
          <PlaceholderImage label="Logo" className="h-20 w-20 shrink-0 rounded-lg bg-white shadow-sm" />
          <div className="pb-1">
            <div className="h-4 w-24 rounded bg-[#e5d9c7]" />
            <div className="mt-3 h-8 w-48 rounded bg-[#e5d9c7]" />
            <div className="mt-2 h-4 w-32 rounded bg-[#efe6d8]" />
          </div>
        </div>
      </section>
      <section className="mx-auto mt-8 grid w-full max-w-4xl gap-3 px-4">
        {[0, 1, 2].map((item) => (
          <div key={item} className="grid grid-cols-[88px_1fr] gap-3 rounded-lg border border-[#eadfce] bg-white p-3 shadow-sm sm:grid-cols-[104px_1fr] sm:gap-4">
            <div className="aspect-square rounded-md bg-[#efe6d8]" />
            <div>
              <div className="h-5 w-40 rounded bg-[#e5d9c7]" />
              <div className="mt-3 h-4 w-full max-w-sm rounded bg-[#f2eadf]" />
              <div className="mt-4 h-4 w-20 rounded bg-[#d4e5d8]" />
            </div>
          </div>
        ))}
      </section>
    </main>
  );
}
