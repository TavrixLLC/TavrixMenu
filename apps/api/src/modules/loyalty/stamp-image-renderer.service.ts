import { BadRequestException, Injectable } from '@nestjs/common';
import { createHash } from 'crypto';
import sharp from 'sharp';
import {
  HEX_COLOR_PATTERN,
  LOYALTY_STAMP_LAYOUT_VARIANTS,
  LOYALTY_STAMP_PRESET_KEYS,
  LOYALTY_WALLET_THEME_PRESETS,
  DEFAULT_LOYALTY_WALLET_THEME,
  LoyaltyStampLayoutVariantValue,
  LoyaltyStampPresetKeyValue,
  LoyaltyWalletThemePresetValue
} from './loyalty-stamp-style.constants';
import {
  resolveWalletPassVisual,
  WalletPassVisualModel
} from './wallet-pass-visual.resolver';

export type StampImageRenderTarget = 'GOOGLE_HERO' | 'APPLE_STRIP';

export type StampImageRenderOptions = {
  target?: StampImageRenderTarget;
  width?: number;
  height?: number;
};

export type StampImageRenderInput = {
  businessName: string;
  programName: string;
  rewardName: string;
  stampCount: number;
  stampGoal: number;
  presetKey: LoyaltyStampPresetKeyValue;
  backgroundColor?: string;
  accentColor?: string;
  textColor?: string;
  imageBackgroundColor?: string;
  imageSurfaceColor?: string;
  imageAccentColor?: string;
  imageTextColor?: string;
  stampFilledColor?: string;
  stampEmptyColor?: string;
  rewardBannerColor?: string;
  themePreset?: LoyaltyWalletThemePresetValue;
  layoutVariant: LoyaltyStampLayoutVariantValue;
};

type NormalizedStampImageRenderInput = StampImageRenderInput & {
  backgroundColor: string;
  accentColor: string;
  textColor: string;
  imageBackgroundColor: string;
  imageSurfaceColor: string;
  imageAccentColor: string;
  imageTextColor: string;
  stampFilledColor: string;
  stampEmptyColor: string;
  rewardBannerColor: string;
  themePreset: LoyaltyWalletThemePresetValue;
  visual: WalletPassVisualModel;
};

type IconInput = {
  x: number;
  y: number;
  size: number;
  fill: string;
  stroke: string;
  filled: boolean;
};

export type AppleStripLayout = {
  width: 1125;
  height: 369;
  columns: number;
  rows: number;
  cellSize: number;
  gap: number;
  gridX: number;
  gridY: number;
  gridWidth: number;
  gridHeight: number;
};

@Injectable()
export class StampImageRendererService {
  async renderPng(
    input: StampImageRenderInput,
    options: StampImageRenderOptions = {}
  ): Promise<Buffer> {
    const normalized = this.normalizeInput(input);
    const svg = this.renderSvg(normalized, options.target);
    const image = sharp(Buffer.from(svg));

    return options.width && options.height
      ? image.resize(options.width, options.height).png().toBuffer()
      : image.png().toBuffer();
  }

  async renderAppleStripPng(input: StampImageRenderInput): Promise<Buffer> {
    const normalized = this.normalizeInput(input);
    const svg = this.renderAppleStripSvg(normalized);

    return sharp(Buffer.from(svg)).png().toBuffer();
  }

  buildAppleStripSvg(input: StampImageRenderInput) {
    return this.renderAppleStripSvg(this.normalizeInput(input));
  }

  getAppleStripLayout(stampGoal: number): AppleStripLayout {
    if (!Number.isInteger(stampGoal) || stampGoal < 1 || stampGoal > 12) {
      throw new BadRequestException('stampGoal must be between 1 and 12');
    }

    const columns =
      stampGoal <= 5
        ? stampGoal
        : stampGoal <= 6
          ? 3
          : stampGoal <= 8
            ? 4
            : stampGoal <= 10
              ? 5
              : 6;
    const rows = Math.ceil(stampGoal / columns);
    const cellSize =
      rows === 1 ? 116 : columns >= 6 ? 72 : columns >= 5 ? 78 : 80;
    const gap = rows === 1 ? 24 : columns >= 6 ? 12 : 14;
    const gridWidth = columns * cellSize + (columns - 1) * gap;
    const gridHeight = rows * cellSize + (rows - 1) * gap;

    return {
      width: 1125,
      height: 369,
      columns,
      rows,
      cellSize,
      gap,
      gridX: Math.round((1125 - gridWidth) / 2),
      gridY: Math.round(120 + (174 - gridHeight) / 2),
      gridWidth,
      gridHeight
    };
  }

  buildStyleHash(input: StampImageRenderInput) {
    const normalized = this.normalizeInput(input);

    return createHash('sha256')
      .update(
        JSON.stringify({
          presetKey: normalized.presetKey,
          backgroundColor: normalized.backgroundColor,
          accentColor: normalized.accentColor,
          textColor: normalized.textColor,
          walletTheme: {
            imageBackgroundColor: normalized.imageBackgroundColor,
            imageSurfaceColor: normalized.imageSurfaceColor,
            imageAccentColor: normalized.imageAccentColor,
            imageTextColor: normalized.imageTextColor,
            stampFilledColor: normalized.stampFilledColor,
            stampEmptyColor: normalized.stampEmptyColor,
            rewardBannerColor: normalized.rewardBannerColor,
            themePreset: normalized.themePreset
          },
          layoutVariant: normalized.layoutVariant
        })
      )
      .digest('hex')
      .slice(0, 16);
  }

  private normalizeInput(
    input: StampImageRenderInput
  ): NormalizedStampImageRenderInput {
    if (!Number.isInteger(input.stampGoal) || input.stampGoal < 1 || input.stampGoal > 12) {
      throw new BadRequestException('stampGoal must be between 1 and 12');
    }

    if (!Number.isInteger(input.stampCount) || input.stampCount < 0) {
      throw new BadRequestException('stampCount cannot be negative');
    }

    if (!LOYALTY_STAMP_PRESET_KEYS.includes(input.presetKey)) {
      throw new BadRequestException('presetKey is not supported');
    }

    if (!LOYALTY_STAMP_LAYOUT_VARIANTS.includes(input.layoutVariant)) {
      throw new BadRequestException('layoutVariant is not supported');
    }

    const themePreset = input.themePreset ?? DEFAULT_LOYALTY_WALLET_THEME.themePreset;

    if (!LOYALTY_WALLET_THEME_PRESETS.includes(themePreset)) {
      throw new BadRequestException('themePreset is not supported');
    }

    const backgroundColor = this.normalizeHexColor(
      input.backgroundColor ?? DEFAULT_LOYALTY_WALLET_THEME.imageBackgroundColor,
      'backgroundColor'
    );
    const accentColor = this.normalizeHexColor(
      input.accentColor ?? DEFAULT_LOYALTY_WALLET_THEME.imageAccentColor,
      'accentColor'
    );
    const textColor = this.normalizeHexColor(
      input.textColor ?? DEFAULT_LOYALTY_WALLET_THEME.imageTextColor,
      'textColor'
    );
    const imageBackgroundColor = this.normalizeHexColor(
      input.imageBackgroundColor ?? backgroundColor,
      'imageBackgroundColor'
    );
    const imageSurfaceColor = this.normalizeHexColor(
      input.imageSurfaceColor ?? DEFAULT_LOYALTY_WALLET_THEME.imageSurfaceColor,
      'imageSurfaceColor'
    );
    const imageAccentColor = this.normalizeHexColor(
      input.imageAccentColor ?? accentColor,
      'imageAccentColor'
    );
    const imageTextColor = this.normalizeHexColor(
      input.imageTextColor ?? textColor,
      'imageTextColor'
    );
    const stampFilledColor = this.normalizeHexColor(
      input.stampFilledColor ?? imageAccentColor,
      'stampFilledColor'
    );
    const stampEmptyColor = this.normalizeHexColor(
      input.stampEmptyColor ?? DEFAULT_LOYALTY_WALLET_THEME.stampEmptyColor,
      'stampEmptyColor'
    );
    const rewardBannerColor = this.normalizeHexColor(
      input.rewardBannerColor ?? DEFAULT_LOYALTY_WALLET_THEME.rewardBannerColor,
      'rewardBannerColor'
    );

    const visual = resolveWalletPassVisual({
      businessName: input.businessName,
      programName: input.programName,
      rewardName: input.rewardName,
      stampCount: input.stampCount,
      stampGoal: input.stampGoal,
      theme: {
        presetKey: input.presetKey,
        backgroundColor,
        accentColor,
        textColor,
        imageBackgroundColor,
        imageSurfaceColor,
        imageAccentColor,
        imageTextColor,
        stampFilledColor,
        stampEmptyColor,
        rewardBannerColor,
        themePreset,
        layoutVariant: input.layoutVariant
      }
    });

    return {
      businessName: visual.businessName,
      programName: visual.programName,
      rewardName: visual.rewardName,
      stampCount: Math.min(input.stampCount, input.stampGoal),
      stampGoal: input.stampGoal,
      presetKey: input.presetKey,
      backgroundColor,
      accentColor,
      textColor,
      imageBackgroundColor,
      imageSurfaceColor,
      imageAccentColor,
      imageTextColor,
      stampFilledColor,
      stampEmptyColor,
      rewardBannerColor,
      themePreset,
      layoutVariant: input.layoutVariant,
      visual
    };
  }

  private renderSvg(
    input: NormalizedStampImageRenderInput,
    target: StampImageRenderTarget = 'GOOGLE_HERO'
  ) {
    const layout = this.getLayout(input.layoutVariant, target);
    const progressBadge = this.getProgressBadge(layout);
    const rawSubtitle =
      input.layoutVariant === 'COMPACT'
        ? input.visual.programName
        : input.visual.businessName;
    const rawHeadline =
      input.layoutVariant === 'COMPACT'
        ? input.visual.businessName
        : input.visual.programName;
    const subtitle = this.fitText(
      rawSubtitle,
      target === 'APPLE_STRIP' ? 38 : 52
    );
    const headline = this.fitText(
      rawHeadline,
      target === 'APPLE_STRIP' ? 34 : 46
    );
    const rewardSummary = this.fitText(
      input.visual.rewardSummary,
      target === 'APPLE_STRIP' ? 58 : 82
    );
    const fontFamily =
      "'Noto Sans', 'Noto Color Emoji', 'DejaVu Sans', sans-serif";

    return [
      `<svg xmlns="http://www.w3.org/2000/svg" width="${layout.width}" height="${layout.height}" viewBox="0 0 ${layout.width} ${layout.height}">`,
      '<defs>',
      `<linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0%" stop-color="${input.imageBackgroundColor}"/><stop offset="100%" stop-color="${this.mixWithBlack(input.imageBackgroundColor, 0.22)}"/></linearGradient>`,
      '<filter id="shadow" x="-20%" y="-20%" width="140%" height="140%"><feDropShadow dx="0" dy="10" stdDeviation="12" flood-color="#000000" flood-opacity="0.24"/></filter>',
      '</defs>',
      `<rect width="100%" height="100%" rx="${layout.radius}" fill="url(#bg)"/>`,
      `<circle cx="${progressBadge.cx}" cy="${progressBadge.cy}" r="${progressBadge.radius}" fill="${this.hexToRgba(input.imageAccentColor, 0.18)}"/>`,
      `<circle cx="76" cy="${layout.height - 40}" r="154" fill="${this.hexToRgba(input.imageTextColor, 0.08)}"/>`,
      `<text x="${layout.padding}" y="${layout.subtitleY}" fill="${this.hexToRgba(input.imageTextColor, 0.78)}" font-family="${fontFamily}" font-size="${layout.subtitleSize}" font-weight="700">${this.escapeXml(subtitle)}</text>`,
      `<text x="${layout.padding}" y="${layout.titleY}" fill="${input.imageTextColor}" font-family="${fontFamily}" font-size="${layout.titleSize}" font-weight="800">${this.escapeXml(headline)}</text>`,
      `<text x="${progressBadge.cx}" y="${progressBadge.labelY}" fill="${this.hexToRgba(input.imageTextColor, 0.78)}" text-anchor="middle" font-family="${fontFamily}" font-size="${layout.subtitleSize}" font-weight="700">${input.visual.progressLabel.toLowerCase()}</text>`,
      `<text x="${progressBadge.cx}" y="${progressBadge.valueY}" fill="${input.imageTextColor}" text-anchor="middle" font-family="${fontFamily}" font-size="${layout.progressSize}" font-weight="800">${input.visual.progressText}</text>`,
      this.renderIconCells(input, layout),
      `<rect x="${layout.padding}" y="${layout.rewardY}" width="${layout.width - layout.padding * 2}" height="${layout.rewardHeight}" rx="${layout.rewardHeight / 2}" fill="${this.hexToRgba(input.rewardBannerColor, 0.86)}"/>`,
      `<text x="${layout.padding + layout.rewardTextInset}" y="${layout.rewardTextY}" fill="${input.imageTextColor}" font-family="${fontFamily}" font-size="${layout.rewardSize}" font-weight="750">${this.escapeXml(rewardSummary)}</text>`,
      '</svg>'
    ].join('');
  }

  private renderAppleStripSvg(input: NormalizedStampImageRenderInput) {
    const layout = this.getAppleStripLayout(input.stampGoal);
    const sanitizedProgramName = this.sanitizeDisplayText(input.programName);
    const sanitizedRewardName = this.sanitizeDisplayText(input.rewardName);
    const titleSize = this.fitFontSize(sanitizedProgramName, 52, 38, 24);
    const rewardText = this.truncate(`Reward: ${sanitizedRewardName}`, 46);
    const rewardSize = this.fitFontSize(rewardText, 31, 23, 38);

    return [
      `<svg xmlns="http://www.w3.org/2000/svg" width="${layout.width}" height="${layout.height}" viewBox="0 0 ${layout.width} ${layout.height}">`,
      '<defs>',
      `<linearGradient id="apple-bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0%" stop-color="${input.imageBackgroundColor}"/><stop offset="100%" stop-color="${this.mixWithBlack(input.imageBackgroundColor, 0.18)}"/></linearGradient>`,
      '<filter id="apple-shadow" x="-30%" y="-30%" width="160%" height="160%"><feDropShadow dx="0" dy="6" stdDeviation="7" flood-color="#000000" flood-opacity="0.22"/></filter>',
      '</defs>',
      '<rect width="1125" height="369" fill="url(#apple-bg)"/>',
      `<circle cx="64" cy="330" r="170" fill="${this.hexToRgba(input.imageTextColor, 0.07)}"/>`,
      `<text x="48" y="76" fill="${input.imageTextColor}" font-family="${this.fontFamily()}" font-size="${titleSize}" font-weight="800">${this.escapeXml(this.truncate(sanitizedProgramName, 34))}</text>`,
      `<rect x="914" y="32" width="163" height="66" rx="33" fill="${this.hexToRgba(input.imageSurfaceColor, 0.92)}" stroke="${this.hexToRgba(input.imageAccentColor, 0.5)}" stroke-width="3"/>`,
      `<text x="995.5" y="58" fill="${this.hexToRgba(input.imageTextColor, 0.74)}" text-anchor="middle" font-family="${this.fontFamily()}" font-size="18" font-weight="700">STAMPS</text>`,
      `<text x="995.5" y="87" fill="${input.imageTextColor}" text-anchor="middle" font-family="${this.fontFamily()}" font-size="30" font-weight="800">${input.stampCount} / ${input.stampGoal}</text>`,
      this.renderAppleIconCells(input, layout),
      `<rect x="48" y="309" width="1029" height="42" rx="21" fill="${this.hexToRgba(input.rewardBannerColor, 0.94)}"/>`,
      `<text x="562.5" y="338" fill="${input.imageTextColor}" text-anchor="middle" font-family="${this.fontFamily()}" font-size="${rewardSize}" font-weight="700">${this.escapeXml(rewardText)}</text>`,
      '</svg>'
    ].join('');
  }

  private renderAppleIconCells(
    input: NormalizedStampImageRenderInput,
    layout: AppleStripLayout
  ) {
    const cells = Array.from({ length: input.stampGoal }, (_, index) => {
      const column = index % layout.columns;
      const row = Math.floor(index / layout.columns);
      const rowItemCount = Math.min(
        layout.columns,
        input.stampGoal - row * layout.columns
      );
      const rowWidth =
        rowItemCount * layout.cellSize + (rowItemCount - 1) * layout.gap;
      const rowStartX = (layout.width - rowWidth) / 2;
      const x = rowStartX + column * (layout.cellSize + layout.gap);
      const y = layout.gridY + row * (layout.cellSize + layout.gap);
      const filled = index < input.stampCount;
      const icon = this.renderPresetIcon(input.presetKey, {
        x: x + layout.cellSize / 2,
        y: y + layout.cellSize / 2,
        size: layout.cellSize * 0.58,
        fill: filled ? input.stampFilledColor : 'none',
        stroke: filled ? input.stampFilledColor : input.stampEmptyColor,
        filled
      });

      return [
        `<g${filled ? ' filter="url(#apple-shadow)"' : ''}>`,
        `<rect data-apple-stamp="${index + 1}" x="${x}" y="${y}" width="${layout.cellSize}" height="${layout.cellSize}" rx="${layout.cellSize * 0.28}" fill="${filled ? this.hexToRgba(input.imageSurfaceColor, 0.94) : this.hexToRgba(input.imageSurfaceColor, 0.42)}" stroke="${filled ? this.hexToRgba(input.stampFilledColor, 0.5) : this.hexToRgba(input.stampEmptyColor, 0.55)}" stroke-width="3"/>`,
        icon,
        '</g>'
      ].join('');
    }).join('');

    return `<g data-stamp-preset="${input.presetKey}">${cells}</g>`;
  }

  private renderIconCells(
    input: NormalizedStampImageRenderInput,
    layout: ReturnType<typeof this.getLayout>
  ) {
    const columns =
      input.stampGoal <= 5
        ? input.stampGoal
        : input.stampGoal <= 6
          ? 3
          : input.stampGoal <= 8
            ? 4
            : input.stampGoal <= 10
              ? 5
              : 6;
    const rows = Math.ceil(input.stampGoal / columns);
    const cellSize =
      input.layoutVariant === 'COMPACT' && rows > 1
        ? 48
        : layout.cellSize;
    const iconGap =
      input.layoutVariant === 'COMPACT' && rows > 1
        ? 10
        : layout.iconGap;
    const gridHeight = rows * cellSize + (rows - 1) * iconGap;
    const startY =
      layout.iconsY + Math.max(0, (layout.iconBoxHeight - gridHeight) / 2);

    return Array.from({ length: input.stampGoal }, (_, index) => {
      const column = index % columns;
      const row = Math.floor(index / columns);
      const rowItemCount = Math.min(
        columns,
        input.stampGoal - row * columns
      );
      const rowWidth = rowItemCount * cellSize + (rowItemCount - 1) * iconGap;
      const rowStartX = (layout.width - rowWidth) / 2;
      const x = rowStartX + column * (cellSize + iconGap);
      const y = startY + row * (cellSize + iconGap);
      const filled = index < input.stampCount;
      const icon = this.renderPresetIcon(input.presetKey, {
        x: x + cellSize / 2,
        y: y + cellSize / 2,
        size: cellSize * 0.7,
        fill: filled ? input.stampFilledColor : 'none',
        stroke: filled ? input.stampFilledColor : input.stampEmptyColor,
        filled
      });

      return [
        `<g filter="${filled ? 'url(#shadow)' : ''}">`,
        `<rect x="${x}" y="${y}" width="${cellSize}" height="${cellSize}" rx="${cellSize * 0.26}" fill="${filled ? this.hexToRgba(input.imageSurfaceColor, 0.92) : this.hexToRgba(input.imageSurfaceColor, 0.48)}" stroke="${filled ? this.hexToRgba(input.stampFilledColor, 0.52) : this.hexToRgba(input.stampEmptyColor, 0.44)}" stroke-width="3"/>`,
        icon,
        '</g>'
      ].join('');
    }).join('');
  }

  private renderPresetIcon(
    presetKey: LoyaltyStampPresetKeyValue,
    input: IconInput
  ) {
    switch (presetKey) {
      case 'STAR':
        return this.starIcon(input);
      case 'COOKIE':
        return this.cookieIcon(input);
      case 'COFFEE':
        return this.coffeeIcon(input);
      case 'BOWL':
        return this.bowlIcon(input);
      case 'BURGER':
        return this.burgerIcon(input);
      case 'PIZZA':
        return this.pizzaIcon(input);
      case 'HEART':
        return this.heartIcon(input);
      case 'CUPCAKE':
        return this.cupcakeIcon(input);
    }
  }

  private starIcon(input: IconInput) {
    const points = Array.from({ length: 10 }, (_, index) => {
      const angle = -Math.PI / 2 + (index * Math.PI) / 5;
      const radius = index % 2 === 0 ? input.size / 2 : input.size * 0.22;

      return `${input.x + Math.cos(angle) * radius},${input.y + Math.sin(angle) * radius}`;
    }).join(' ');

    return `<polygon points="${points}" fill="${input.fill}" stroke="${input.stroke}" stroke-width="7" stroke-linejoin="round"/>`;
  }

  private cookieIcon(input: IconInput) {
    const chips = input.filled
      ? [
          [-0.12, -0.16],
          [0.14, -0.02],
          [-0.2, 0.18],
          [0.21, 0.24]
        ]
      : [];
    const chipSvg = chips
      .map(
        ([dx, dy]) =>
          `<circle cx="${input.x + input.size * dx}" cy="${input.y + input.size * dy}" r="${input.size * 0.045}" fill="#6b3f16"/>`
      )
      .join('');

    return `<circle cx="${input.x}" cy="${input.y}" r="${input.size / 2}" fill="${input.fill}" stroke="${input.stroke}" stroke-width="7"/>${chipSvg}`;
  }

  private coffeeIcon(input: IconInput) {
    const x = input.x - input.size * 0.36;
    const y = input.y - input.size * 0.26;
    const w = input.size * 0.62;
    const h = input.size * 0.52;

    return [
      `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${input.size * 0.12}" fill="${input.fill}" stroke="${input.stroke}" stroke-width="7"/>`,
      `<path d="M ${x + w} ${y + h * 0.18} C ${x + w + input.size * 0.26} ${y + h * 0.12}, ${x + w + input.size * 0.26} ${y + h * 0.78}, ${x + w} ${y + h * 0.72}" fill="none" stroke="${input.stroke}" stroke-width="7" stroke-linecap="round"/>`,
      `<path d="M ${x + input.size * 0.1} ${y - input.size * 0.12} C ${x + input.size * 0.1} ${y - input.size * 0.22}, ${x + input.size * 0.24} ${y - input.size * 0.22}, ${x + input.size * 0.24} ${y - input.size * 0.34}" fill="none" stroke="${input.stroke}" stroke-width="5" stroke-linecap="round"/>`
    ].join('');
  }

  private bowlIcon(input: IconInput) {
    const x = input.x - input.size * 0.5;
    const y = input.y - input.size * 0.2;

    return [
      `<path d="M ${x} ${y} H ${x + input.size} C ${x + input.size * 0.86} ${y + input.size * 0.52}, ${x + input.size * 0.66} ${y + input.size * 0.72}, ${x + input.size * 0.5} ${y + input.size * 0.72} C ${x + input.size * 0.34} ${y + input.size * 0.72}, ${x + input.size * 0.14} ${y + input.size * 0.52}, ${x} ${y} Z" fill="${input.fill}" stroke="${input.stroke}" stroke-width="7" stroke-linejoin="round"/>`,
      `<path d="M ${x + input.size * 0.18} ${y - input.size * 0.17} C ${x + input.size * 0.38} ${y - input.size * 0.32}, ${x + input.size * 0.62} ${y - input.size * 0.32}, ${x + input.size * 0.82} ${y - input.size * 0.17}" fill="none" stroke="${input.stroke}" stroke-width="6" stroke-linecap="round"/>`
    ].join('');
  }

  private burgerIcon(input: IconInput) {
    const x = input.x - input.size * 0.48;
    const y = input.y - input.size * 0.36;

    return [
      `<path d="M ${x + input.size * 0.08} ${y + input.size * 0.28} C ${x + input.size * 0.18} ${y - input.size * 0.1}, ${x + input.size * 0.82} ${y - input.size * 0.1}, ${x + input.size * 0.92} ${y + input.size * 0.28} Z" fill="${input.fill}" stroke="${input.stroke}" stroke-width="7" stroke-linejoin="round"/>`,
      `<path d="M ${x + input.size * 0.08} ${y + input.size * 0.48} H ${x + input.size * 0.92}" stroke="${input.stroke}" stroke-width="8" stroke-linecap="round"/>`,
      `<path d="M ${x + input.size * 0.12} ${y + input.size * 0.68} H ${x + input.size * 0.88}" stroke="${input.stroke}" stroke-width="8" stroke-linecap="round"/>`,
      `<path d="M ${x + input.size * 0.18} ${y + input.size * 0.84} H ${x + input.size * 0.82}" stroke="${input.stroke}" stroke-width="8" stroke-linecap="round"/>`
    ].join('');
  }

  private pizzaIcon(input: IconInput) {
    const topX = input.x;
    const topY = input.y - input.size * 0.48;
    const leftX = input.x - input.size * 0.42;
    const bottomY = input.y + input.size * 0.4;
    const rightX = input.x + input.size * 0.42;
    const toppings = input.filled
      ? [
          `<circle cx="${input.x - input.size * 0.1}" cy="${input.y - input.size * 0.02}" r="${input.size * 0.05}" fill="#dc2626"/>`,
          `<circle cx="${input.x + input.size * 0.12}" cy="${input.y + input.size * 0.16}" r="${input.size * 0.045}" fill="#dc2626"/>`
        ].join('')
      : '';

    return `<path d="M ${topX} ${topY} L ${rightX} ${bottomY} L ${leftX} ${bottomY} Z" fill="${input.fill}" stroke="${input.stroke}" stroke-width="7" stroke-linejoin="round"/>${toppings}`;
  }

  private heartIcon(input: IconInput) {
    const s = input.size / 100;
    const d = [
      `M ${input.x} ${input.y + 34 * s}`,
      `C ${input.x - 54 * s} ${input.y - 10 * s}, ${input.x - 40 * s} ${input.y - 52 * s}, ${input.x - 7 * s} ${input.y - 32 * s}`,
      `C ${input.x + 26 * s} ${input.y - 52 * s}, ${input.x + 54 * s} ${input.y - 10 * s}, ${input.x} ${input.y + 34 * s}`,
      'Z'
    ].join(' ');

    return `<path d="${d}" fill="${input.fill}" stroke="${input.stroke}" stroke-width="7" stroke-linejoin="round"/>`;
  }

  private cupcakeIcon(input: IconInput) {
    const x = input.x - input.size * 0.42;
    const y = input.y - input.size * 0.44;

    return [
      `<path d="M ${x + input.size * 0.12} ${y + input.size * 0.36} C ${x + input.size * 0.12} ${y + input.size * 0.06}, ${x + input.size * 0.88} ${y + input.size * 0.06}, ${x + input.size * 0.88} ${y + input.size * 0.36}" fill="${input.fill}" stroke="${input.stroke}" stroke-width="7" stroke-linecap="round"/>`,
      `<path d="M ${x + input.size * 0.18} ${y + input.size * 0.42} H ${x + input.size * 0.82} L ${x + input.size * 0.72} ${y + input.size * 0.88} H ${x + input.size * 0.28} Z" fill="${input.fill}" stroke="${input.stroke}" stroke-width="7" stroke-linejoin="round"/>`
    ].join('');
  }

  private getLayout(
    variant: LoyaltyStampLayoutVariantValue,
    target: StampImageRenderTarget = 'GOOGLE_HERO'
  ) {
    if (target === 'APPLE_STRIP') {
      return {
        width: 750,
        height: 246,
        radius: 0,
        padding: 28,
        subtitleY: 29,
        titleY: 62,
        subtitleSize: 14,
        titleSize: 27,
        progressSize: 27,
        badgeRadius: 48,
        badgeTopSafePadding: 8,
        badgeRightSafePadding: 24,
        badgeLabelOffset: -12,
        badgeValueOffset: 21,
        iconsY: 79,
        iconBoxHeight: 88,
        cellSize: 58,
        iconGap: 6,
        rewardY: 181,
        rewardHeight: 40,
        rewardTextY: 208,
        rewardSize: 18,
        rewardTextInset: 20,
        singleRow: true
      };
    }

    if (variant === 'COMPACT') {
      return {
        width: 1032,
        height: 336,
        radius: 36,
        padding: 48,
        subtitleY: 54,
        titleY: 102,
        subtitleSize: 22,
        titleSize: 40,
        progressSize: 40,
        badgeRadius: 80,
        badgeTopSafePadding: 18,
        badgeRightSafePadding: 24,
        badgeLabelOffset: -26,
        badgeValueOffset: 28,
        iconsY: 128,
        iconBoxHeight: 116,
        cellSize: 88,
        iconGap: 8,
        rewardY: 264,
        rewardHeight: 44,
        rewardTextY: 294,
        rewardSize: 22,
        rewardTextInset: 28,
        singleRow: true
      };
    }

    return {
      width: 1200,
      height: 628,
      radius: 48,
      padding: 72,
      subtitleY: 82,
      titleY: 148,
      subtitleSize: 28,
      titleSize: 56,
      progressSize: 56,
      badgeRadius: 124,
      badgeTopSafePadding: 32,
      badgeRightSafePadding: 40,
      badgeLabelOffset: -48,
      badgeValueOffset: 28,
      iconsY: 206,
      iconBoxHeight: 260,
      cellSize: 112,
      iconGap: 20,
      rewardY: 520,
      rewardHeight: 58,
      rewardTextY: 558,
      rewardSize: 28,
      rewardTextInset: 28,
      singleRow: false
    };
  }

  private getProgressBadge(layout: ReturnType<typeof this.getLayout>) {
    const cx =
      layout.width - layout.badgeRightSafePadding - layout.badgeRadius;
    const cy = layout.badgeTopSafePadding + layout.badgeRadius;

    return {
      cx,
      cy,
      radius: layout.badgeRadius,
      labelY: cy + layout.badgeLabelOffset,
      valueY: cy + layout.badgeValueOffset
    };
  }

  private normalizeHexColor(value: string, fieldName: string) {
    const normalized = value.trim();

    if (!HEX_COLOR_PATTERN.test(normalized)) {
      throw new BadRequestException(`${fieldName} must be a valid hex color`);
    }

    return normalized;
  }

  private mixWithBlack(hex: string, amount: number) {
    const [r, g, b] = this.hexToRgb(hex);

    return this.rgbToHex(
      Math.round(r * (1 - amount)),
      Math.round(g * (1 - amount)),
      Math.round(b * (1 - amount))
    );
  }

  private hexToRgba(hex: string, alpha: number) {
    const [r, g, b] = this.hexToRgb(hex);

    return `rgba(${r},${g},${b},${alpha})`;
  }

  private hexToRgb(hex: string): [number, number, number] {
    const normalized =
      hex.length === 4
        ? `#${hex[1]}${hex[1]}${hex[2]}${hex[2]}${hex[3]}${hex[3]}`
        : hex;

    return [
      Number.parseInt(normalized.slice(1, 3), 16),
      Number.parseInt(normalized.slice(3, 5), 16),
      Number.parseInt(normalized.slice(5, 7), 16)
    ];
  }

  private rgbToHex(r: number, g: number, b: number) {
    return `#${[r, g, b]
      .map((value) => value.toString(16).padStart(2, '0'))
      .join('')}`;
  }

  private escapeXml(value: string) {
    return value
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&apos;');
  }

  private sanitizeDisplayText(value: string) {
    return value
      .replace(/[\u0000-\u001f\u007f]/g, ' ')
      .replace(/\p{Extended_Pictographic}/gu, ' ')
      .replace(/[\u200d\ufe0e\ufe0f]/g, '')
      .replace(/\s+/g, ' ')
      .trim();
  }

  private fitFontSize(
    value: string,
    preferred: number,
    minimum: number,
    preferredLength: number
  ) {
    const length = Array.from(value).length;

    if (length <= preferredLength) {
      return preferred;
    }

    return Math.max(
      minimum,
      Math.floor(preferred * (preferredLength / length))
    );
  }

  private fontFamily() {
    return 'DejaVu Sans, Noto Sans, Arial, sans-serif';
  }

  private truncate(value: string, maxLength: number) {
    const characters = Array.from(value);

    return characters.length <= maxLength
      ? value
      : `${characters.slice(0, maxLength - 3).join('')}...`;
  }

  private fitText(value: string, maxCharacters: number) {
    const characters = Array.from(value);

    return characters.length <= maxCharacters
      ? value
      : `${characters.slice(0, maxCharacters - 3).join('')}...`;
  }
}
