export function publicLoginDestination(redirect: unknown): string {
 return typeof redirect === 'string' && /^\/m(?:\/(?:home|todos|apps|messages|profile|announcements|applications)(?:\/[^/?#]+)?)?(?:\?[^#]*)?$/.test(redirect)
  ? redirect
  : '/portal/home';
}
