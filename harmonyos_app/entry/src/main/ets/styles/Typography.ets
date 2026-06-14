// styles/Typography.ets — M4-T01: 字体排版
import { Colors, FontSize } from './DesignTokens'

export const TitleFont = {
  fontSize: FontSize.xl,
  fontWeight: FontWeight.Bold,
  fontColor: Colors.primary
}

export const SectionTitle = {
  fontSize: FontSize.md,
  fontWeight: FontWeight.Bold,
  fontColor: Colors.textPrimary
}

export const BodyText = {
  fontSize: FontSize.md,
  fontColor: Colors.textPrimary
}

export const CaptionText = {
  fontSize: FontSize.sm,
  fontColor: Colors.textSecondary
}

export const MetaText = {
  fontSize: FontSize.xs,
  fontColor: Colors.textTertiary
}

export const LinkText = {
  fontSize: FontSize.sm,
  fontColor: Colors.linkBlue,
  decoration: { type: TextDecorationType.Underline }
}
