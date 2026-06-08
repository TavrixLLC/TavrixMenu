type CardPageProps = {
  params: Promise<{
    cardToken: string;
  }>;
};

export default async function CardPage({ params }: CardPageProps) {
  const { cardToken } = await params;

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-md flex-col justify-center px-6 py-12">
      <p className="text-sm font-semibold uppercase tracking-wide text-mint">Customer card</p>
      <h1 className="mt-3 text-3xl font-bold text-ink">Tavrix Menu Card</h1>
      <p className="mt-4 rounded-md border border-neutral-200 bg-white p-4 text-sm text-neutral-600">
        Token: <span className="font-semibold text-ink">{cardToken}</span>
      </p>
    </main>
  );
}
