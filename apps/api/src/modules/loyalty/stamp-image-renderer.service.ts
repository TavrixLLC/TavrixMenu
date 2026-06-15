import { BadRequestException, Injectable } from '@nestjs/common';
import { createHash } from 'crypto';
import sharp from 'sharp';
import {
  HEX_COLOR_PATTERN,
  LOYALTY_STAMP_LAYOUT_VARIANTS,
  LOYALTY_STAMP_PRESET_KEYS,
  LoyaltyStampLayoutVariantValue,
  LoyaltyStampPresetKeyValue
} from './loyalty-stamp-style.constants';

export type StampImageRenderInput = {
  businessName: string;
  programName: string;
  rewardName: string;
  stampCount: number;
  stampGoal: number;
  presetKey: LoyaltyStampPresetKeyValue;
  backgroundColor: string;
  accentColor: string;
  textColor: string;
  layoutVariant: LoyaltyStampLayoutVariantValue;
};

type IconInput = {
  x: number;
  y: number;
  size: number;
  fill: string;
  stroke: string;
  filled: boolean;
};

@Injectable()
export class StampImageRendererService {
  async renderPng(input: StampImageRenderInput): Promise<Buffer> {
    const normalized = this.normalizeInput(input);
    const svg = this.renderSvg(normalized);

    return sharp(Buffer.from(svg)).png().toBuffer();
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
          layoutVariant: normalized.layoutVariant
        })
      )
      .digest('hex')
      .slice(0, 16);
  }

  private normalizeInput(input: StampImageRenderInput): StampImageRenderInput {
    if (!Number.isInteger(input.stampGoal) || input.stampGoal < 1 || input.stampGoal > 10) {
      throw new BadRequestException('stampGoal must be between 1 and 10');
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

    return {
      businessName: this.truncate(input.businessName.trim() || 'Waflo', 64),
      programName: this.truncate(input.programName.trim() || 'Loyalty Card', 64),
      rewardName: this.truncate(input.rewardName.trim() || 'Reward', 72),
      stampCount: Math.min(input.stampCount, input.stampGoal),
      stampGoal: input.stampGoal,
      presetKey: input.presetKey,
      backgroundColor: this.normalizeHexColor(
        input.backgroundColor,
        'backgroundColor'
      ),
      accentColor: this.normalizeHexColor(input.accentColor, 'accentColor'),
      textColor: this.normalizeHexColor(input.textColor, 'textColor'),
      layoutVariant: input.layoutVariant
    };
  }

  private renderSvg(input: StampImageRenderInput) {
    const layout = this.getLayout(input.layoutVariant);
    const subtitle =
      input.layoutVariant === 'COMPACT' ? input.programName : input.businessName;
    const headline =
      input.layoutVariant === 'COMPACT' ? input.businessName : input.programName;

    return [
      `<svg xmlns="http://www.w3.org/2000/svg" width="${layout.width}" height="${layout.height}" viewBox="0 0 ${layout.width} ${layout.height}">`,
      '<defs>',
      `<linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0%" stop-color="${input.backgroundColor}"/><stop offset="100%" stop-color="${this.mixWithBlack(input.backgroundColor, 0.22)}"/></linearGradient>`,
      '<filter id="shadow" x="-20%" y="-20%" width="140%" height="140%"><feDropShadow dx="0" dy="10" stdDeviation="12" flood-color="#000000" flood-opacity="0.24"/></filter>',
      '</defs>',
      `<rect width="100%" height="100%" rx="${layout.radius}" fill="url(#bg)"/>`,
      `<circle cx="${layout.width - 118}" cy="84" r="158" fill="${this.hexToRgba(input.accentColor, 0.14)}"/>`,
      `<circle cx="76" cy="${layout.height - 40}" r="154" fill="${this.hexToRgba(input.textColor, 0.08)}"/>`,
      `<text x="${layout.padding}" y="${layout.subtitleY}" fill="${this.hexToRgba(input.textColor, 0.78)}" font-family="Inter, Arial, sans-serif" font-size="${layout.subtitleSize}" font-weight="700">${this.escapeXml(subtitle)}</text>`,
      `<text x="${layout.padding}" y="${layout.titleY}" fill="${input.textColor}" font-family="Inter, Arial, sans-serif" font-size="${layout.titleSize}" font-weight="800">${this.escapeXml(headline)}</text>`,
      `<text x="${layout.width - layout.padding}" y="${layout.titleY}" fill="${input.textColor}" text-anchor="end" font-family="Inter, Arial, sans-serif" font-size="${layout.progressSize}" font-weight="800">${input.stampCount} / ${input.stampGoal}</text>`,
      `<text x="${layout.width - layout.padding}" y="${layout.subtitleY}" fill="${this.hexToRgba(input.textColor, 0.78)}" text-anchor="end" font-family="Inter, Arial, sans-serif" font-size="${layout.subtitleSize}" font-weight="700">stamps</text>`,
      this.renderIconCells(input, layout),
      `<rect x="${layout.padding}" y="${layout.rewardY}" width="${layout.width - layout.padding * 2}" height="${layout.rewardHeight}" rx="${layout.rewardHeight / 2}" fill="${this.hexToRgba(input.textColor, 0.12)}"/>`,
      `<text x="${layout.padding + 28}" y="${layout.rewardTextY}" fill="${input.textColor}" font-family="Inter, Arial, sans-serif" font-size="${layout.rewardSize}" font-weight="750">${this.escapeXml(`Reward: ${input.rewardName}`)}</text>`,
      '</svg>'
    ].join('');
  }

  private renderIconCells(
    input: StampImageRenderInput,
    layout: ReturnType<typeof this.getLayout>
  ) {
    const columns = input.layoutVariant === 'COMPACT' ? input.stampGoal : 5;
    const rows = Math.ceil(input.stampGoal / columns);
    const gridWidth =
      columns * layout.cellSize + (columns - 1) * layout.iconGap;
    const gridHeight = rows * layout.cellSize + (rows - 1) * layout.iconGap;
    const startX = (layout.width - gridWidth) / 2;
    const startY =
      layout.iconsY + Math.max(0, (layout.iconBoxHeight - gridHeight) / 2);

    return Array.from({ length: input.stampGoal }, (_, index) => {
      const column = index % columns;
      const row = Math.floor(index / columns);
      const x = startX + column * (layout.cellSize + layout.iconGap);
      const y = startY + row * (layout.cellSize + layout.iconGap);
      const filled = index < input.stampCount;
      const icon = this.renderPresetIcon(input.presetKey, {
        x: x + layout.cellSize / 2,
        y: y + layout.cellSize / 2,
        size: layout.cellSize * 0.7,
        fill: filled ? input.accentColor : 'none',
        stroke: filled
          ? input.accentColor
          : this.hexToRgba(input.textColor, 0.56),
        filled
      });

      return [
        `<g filter="${filled ? 'url(#shadow)' : ''}">`,
        `<rect x="${x}" y="${y}" width="${layout.cellSize}" height="${layout.cellSize}" rx="${layout.cellSize * 0.26}" fill="${filled ? this.hexToRgba(input.textColor, 0.12) : this.hexToRgba(input.textColor, 0.06)}" stroke="${filled ? this.hexToRgba(input.accentColor, 0.4) : this.hexToRgba(input.textColor, 0.18)}" stroke-width="3"/>`,
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

  private getLayout(variant: LoyaltyStampLayoutVariantValue) {
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
        iconsY: 128,
        iconBoxHeight: 116,
        cellSize: 88,
        iconGap: 8,
        rewardY: 264,
        rewardHeight: 44,
        rewardTextY: 294,
        rewardSize: 22
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
      iconsY: 206,
      iconBoxHeight: 260,
      cellSize: 112,
      iconGap: 20,
      rewardY: 520,
      rewardHeight: 58,
      rewardTextY: 558,
      rewardSize: 28
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

  private truncate(value: string, maxLength: number) {
    return value.length <= maxLength
      ? value
      : `${value.slice(0, maxLength - 3)}...`;
  }
}
