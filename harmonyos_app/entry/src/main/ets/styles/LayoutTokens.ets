// styles/LayoutTokens.ets — M4-T01: 布局断点和设备适配
import { Layout } from './DesignTokens'

export enum DeviceClass { COMPACT, MEDIUM, EXPANDED }

export function getDeviceClass(width: number): DeviceClass {
  if (width < Layout.breakpointCompact) return DeviceClass.COMPACT
  if (width < Layout.breakpointMedium) return DeviceClass.MEDIUM
  return DeviceClass.EXPANDED
}

export function isCompact(width: number): boolean { return width < Layout.breakpointCompact }
export function isMedium(width: number): boolean { return width >= Layout.breakpointCompact && width < Layout.breakpointMedium }
export function isExpanded(width: number): boolean { return width >= Layout.breakpointMedium }
