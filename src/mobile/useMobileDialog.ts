import {nextTick,onBeforeUnmount,watch,type Ref} from 'vue';

const FOCUSABLE = 'button:not([disabled]),[href],input:not([disabled]),textarea:not([disabled]),select:not([disabled]),[tabindex]:not([tabindex="-1"])';
const RESTORE_TIMEOUT_MS = 3000;

type DialogOptions = {
 open: Ref<boolean>;
 element: Ref<HTMLElement|null>;
 close: () => void;
 restore?: () => HTMLElement|null;
};

export function useMobileDialog({open,element,close,restore}:DialogOptions) {
 let previousFocus: HTMLElement|null = null;
 let previousOverflow = '';
 let locked = false;
 let restoreObserver: MutationObserver|null = null;
 let restoreTimer: number|undefined;

 function stopRestoring() {
  restoreObserver?.disconnect();
  restoreObserver = null;
  window.clearTimeout(restoreTimer);
 }
 function restoreFocus() {
  const target = restore ? restore() : (previousFocus?.isConnected ? previousFocus : null);
  if (target) { target.focus(); stopRestoring(); return; }
  if (!restore) return;
  stopRestoring();
  restoreObserver = new MutationObserver(() => {
   const next = restore();
   if (next) { next.focus(); stopRestoring(); }
  });
  restoreObserver.observe(document.body,{childList:true,subtree:true});
  restoreTimer = window.setTimeout(stopRestoring,RESTORE_TIMEOUT_MS);
 }
 function release() {
  if (!locked) return;
  document.removeEventListener('keydown',onKeydown);
  document.body.style.overflow = previousOverflow;
  locked = false;
 }
 function onKeydown(event:KeyboardEvent) {
  if (event.key === 'Escape') { event.preventDefault(); close(); return; }
  if (event.key !== 'Tab' || !element.value) return;
  const focusable = [...element.value.querySelectorAll<HTMLElement>(FOCUSABLE)].filter(node => node.getClientRects().length > 0);
  if (!focusable.length) { event.preventDefault(); element.value.focus(); return; }
  const first = focusable[0],last = focusable[focusable.length - 1];
  if (event.shiftKey && (document.activeElement === first || !element.value.contains(document.activeElement))) { event.preventDefault(); last.focus(); }
  else if (!event.shiftKey && (document.activeElement === last || !element.value.contains(document.activeElement))) { event.preventDefault(); first.focus(); }
 }

 watch([open,element],async ([visible]) => {
  if (visible) {
   if (!locked) {
    stopRestoring();
    previousFocus = document.activeElement instanceof HTMLElement ? document.activeElement : null;
    previousOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    document.addEventListener('keydown',onKeydown);
    locked = true;
   }
   await nextTick();
   if (open.value) (element.value?.querySelector<HTMLElement>(FOCUSABLE) || element.value)?.focus();
   return;
  }
  if (!locked) return;
  release();
  await nextTick();
  restoreFocus();
 },{immediate:true,flush:'post'});
 onBeforeUnmount(() => { if (locked) { release(); restoreFocus(); } });
 return {closeDialog:close};
}
