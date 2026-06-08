type PlaceholderImageProps = {
  label: string;
  className?: string;
};

export function PlaceholderImage({ label, className = '' }: PlaceholderImageProps) {
  return (
    <div
      className={`flex items-center justify-center rounded border border-dashed border-neutral-300 bg-white text-sm font-medium text-neutral-500 ${className}`}
    >
      {label}
    </div>
  );
}
