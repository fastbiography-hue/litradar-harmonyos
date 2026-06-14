// styles/Spacing.ets — M4-T01: 间距 & 布局辅助
import { Spacing, Layout } from './DesignTokens'

// Standard padding for cards and panels
export const cardPadding = { left: Spacing.lg, right: Spacing.lg, top: Spacing.md, bottom: Spacing.md }
export const listItemPadding = { left: Spacing.sm, right: Spacing.sm }
export const sectionMargin = { bottom: Spacing.md }

// Desktop-specific
export const sidebarWidth = Layout.desktopSidebarWidth
export const toolbarHeight = Layout.toolbarHeight
export const listHeaderHeight = Layout.listHeaderHeight
