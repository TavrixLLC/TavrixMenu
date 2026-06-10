type PlaceholderImageProps = {
  label: string;
  className?: string;
};

export function PlaceholderImage({ label, className = '' }: PlaceholderImageProps) {
  return (
    <div
      className={`relative flex items-center justify-center overflow-hidden rounded border border-dashed border-[#d8cbb8] bg-[#f5efe5] text-sm font-semibold text-[#6f5a3f] ${className}`}
    >
      <div className="absolute inset-0 bg-[linear-gradient(135deg,rgba(255,255,255,0.75),rgba(31,122,90,0.08))]" />
      <span className="relative px-3 text-center">{label}</span>
    </div>
  );
}
