// styles/DesignTokens.ets — M4-T01: 统一设计 token
export interface ColorTokens {
  primary: string; background: string; surface: string
  textPrimary: string; textSecondary: string; textTertiary: string
  border: string; success: string; warning: string; error: string
  oaGreen: string; oaBg: string; highScoreBg: string
  toolbarBg: string; toolbarBorder: string
  scoreGreen: string; scoreOrange: string; scoreGray: string; linkBlue: string
}
export interface SpacingTokens { xs: number; sm: number; md: number; lg: number; xl: number; xxl: number }
export interface RadiusTokens { sm: number; md: number; lg: number }
export interface FontSizeTokens { xs: number; sm: number; md: number; lg: number; xl: number }
export interface LayoutTokens {
  desktopSidebarWidth: number; desktopDetailWidth: number
  mobileBottomTabHeight: number; cardMinHeight: number; toolbarHeight: number
  listHeaderHeight: number; breakpointCompact: number; breakpointMedium: number
}

export const Colors: ColorTokens = {
  primary: '#2F5496', background: '#FFFFFF', surface: '#F5F5F5',
  textPrimary: '#1A1A1A', textSecondary: '#666666', textTertiary: '#AAAAAA',
  border: '#E0E0E0', success: '#52C41A', warning: '#FA8C16', error: '#FF4D4F',
  oaGreen: '#006100', oaBg: '#C6EFCE', highScoreBg: '#E8EEF8',
  toolbarBg: '#F0F4FF', toolbarBorder: '#D0D9F0',
  scoreGreen: '#52C41A', scoreOrange: '#FA8C16', scoreGray: '#AAAAAA', linkBlue: '#0563C1'
}

export const Spacing: SpacingTokens = { xs: 4, sm: 8, md: 12, lg: 16, xl: 20, xxl: 24 }
export const Radius: RadiusTokens = { sm: 3, md: 6, lg: 12 }
export const FontSize: FontSizeTokens = { xs: 9, sm: 11, md: 13, lg: 16, xl: 20 }
export const Layout: LayoutTokens = {
  desktopSidebarWidth: 220, desktopDetailWidth: 320, mobileBottomTabHeight: 56,
  cardMinHeight: 72, toolbarHeight: 56, listHeaderHeight: 36,
  breakpointCompact: 600, breakpointMedium: 1024
}
