/* ============================================================
   Core state, calculations, formatting and actions
   ============================================================ */

const DAY = 86400;
const WEEK = 7 * DAY;
const PREFS_KEY = "iquit-prototype-prefs";

function demoState() {
  const now = Date.now();
  const elapsed = 12 * DAY + 4 * 3600 + 32 * 60;
  return {
    quitDate: now - elapsed * 1000,
    product: "cigarettes",
    unitsPerDay: 20,
    pricePerPackage: 250,
    unitsPerPackage: 20,
    currency: "RUB",
    priorCleanSec: 0,
    bestStreakSec: elapsed,
    savedBase: 0,
    avoidedBase: 0,
    slips: 0,
    notifications: true,
    unlocked: [],
    lang: "ru",
    theme: "light"
  };
}

const state = demoState();

const onboarding = {
  open: false,
  mode: "new",
  step: 1,
  product: "cigarettes",
  quitDate: Date.now(),
  units: 20,
  price: 250,
  pack: 20,
  currency: "RUB",
  notifications: true
};

const ui = {
  screen: "home",
  sheet: null,
  toast: null,
  toastTimer: null,
  slipSnapshot: null,
  lastMilestoneCount: 0,
  lastAchievementCount: 0
};

/* ---------------- i18n helpers ---------------- */
function t(key) {
  const dict = I18N[state.lang] || I18N.ru;
  return dict[key] != null ? dict[key] : key;
}

function locale() {
  return state.lang === "ru" ? "ru-RU" : "en-US";
}

function word(n, key) {
  const abs = Math.abs(Math.round(n));
  if (state.lang === "en") return abs === 1 ? t(key) : t(key + "s");
  const n10 = abs % 10;
  const n100 = abs % 100;
  if (n10 === 1 && n100 !== 11) return t(key);
  if (n10 >= 2 && n10 <= 4 && (n100 < 12 || n100 > 14)) return t(key + "s");
  return t(key + "sMany");
}

function pluralDays(n) { return word(n, "day"); }

function unitWord(n, product) {
  const forms = product.unitForms;
  if (!forms) return product.unitShort[state.lang];
  const abs = Math.abs(Math.round(n));
  if (state.lang === "en") return abs === 1 ? forms.en.one : forms.en.many;
  const n10 = abs % 10;
  const n100 = abs % 100;
  if (n10 === 1 && n100 !== 11) return forms.ru.one;
  if (n10 >= 2 && n10 <= 4 && (n100 < 12 || n100 > 14)) return forms.ru.few;
  return forms.ru.many;
}

/* ---------------- Formatting ---------------- */
function fmtNumber(n, digits = 0) {
  return new Intl.NumberFormat(locale(), { maximumFractionDigits: digits }).format(n);
}

function fmtMoney(n, currencyCode) {
  const value = Math.floor(Math.max(0, n));
  const code = CURRENCIES[currencyCode] ? currencyCode : (CURRENCIES[state.currency] ? state.currency : "RUB");
  const info = CURRENCIES[code];
  const num = fmtNumber(value);
  if (state.lang === "en") return info.symbol.length > 1 ? info.symbol + " " + num : info.symbol + num;
  return num + " " + info.symbol;
}

function fmtDays(n) {
  const value = Math.floor(Math.max(0, n));
  return value + " " + pluralDays(value);
}

function fmtDate(ts, style = "long") {
  const date = new Date(ts);
  const opts = style === "long"
    ? { weekday: "long", day: "numeric", month: "long" }
    : style === "datetime"
      ? { day: "numeric", month: "short", year: "numeric", hour: "2-digit", minute: "2-digit" }
      : { day: "numeric", month: "short" };
  return new Intl.DateTimeFormat(locale(), opts).format(date);
}

function pad2(n) {
  return String(n).padStart(2, "0");
}

function fmtHMS(totalSec) {
  const sec = Math.max(0, Math.floor(totalSec));
  const h = Math.floor((sec % DAY) / 3600);
  const m = Math.floor((sec % 3600) / 60);
  const s = sec % 60;
  return pad2(h) + ":" + pad2(m) + ":" + pad2(s);
}

function fmtDurationShort(totalSec) {
  const sec = Math.max(0, Math.round(totalSec));
  const d = Math.floor(sec / DAY);
  const h = Math.floor((sec % DAY) / 3600);
  const m = Math.floor((sec % 3600) / 60);
  const s = sec % 60;
  const ru = state.lang === "ru";
  if (d > 0) return d + (ru ? " д " : "d ") + h + (ru ? " ч" : "h");
  if (h > 0) return h + (ru ? " ч " : "h ") + m + (ru ? " мин" : "m");
  if (m > 0) return m + (ru ? " мин" : "m");
  return s + (ru ? " сек" : "s");
}

function fmtCountdown(totalSec) {
  if (totalSec <= 0) return t("allDone");
  return t("nextIn") + " " + fmtDurationShort(totalSec);
}

function toLocalInput(ts) {
  const d = new Date(ts);
  return (
    d.getFullYear() + "-" + pad2(d.getMonth() + 1) + "-" + pad2(d.getDate()) +
    "T" + pad2(d.getHours()) + ":" + pad2(d.getMinutes())
  );
}

function fromLocalInput(value) {
  const ts = new Date(value).getTime();
  return Number.isFinite(ts) ? ts : null;
}

/* ---------------- Derived values ---------------- */
function getElapsedSec() {
  return Math.max(0, (Date.now() - state.quitDate) / 1000);
}

function getCostPerDay() {
  if (state.product === "hookah") {
    return state.pricePerPackage * state.unitsPerDay;
  }
  const perUnit = state.pricePerPackage / Math.max(1, state.unitsPerPackage);
  return perUnit * state.unitsPerDay;
}

function getSavedTotal() {
  return state.savedBase + getCostPerDay() * (getElapsedSec() / DAY);
}

function getAvoidedTotal() {
  return state.avoidedBase + state.unitsPerDay * (getElapsedSec() / DAY);
}

function getTotalCleanSec() {
  return state.priorCleanSec + getElapsedSec();
}

function getBestSec() {
  return Math.max(state.bestStreakSec, getElapsedSec());
}

function getCurrentDays() {
  return Math.floor(getElapsedSec() / DAY);
}

function getTotalDays() {
  return Math.floor(getTotalCleanSec() / DAY);
}

function getBestDays() {
  return Math.floor(getBestSec() / DAY);
}

function getProduct() {
  return PRODUCTS[state.product] || PRODUCTS.cigarettes;
}

function getMilestoneState() {
  const elapsed = getElapsedSec();
  const unlocked = MILESTONES.filter(function (m) { return elapsed >= m.at; });
  const next = MILESTONES.find(function (m) { return elapsed < m.at; }) || null;
  const prev = unlocked.length ? unlocked[unlocked.length - 1] : null;
  const start = prev ? prev.at : 0;
  const end = next ? next.at : Math.max(elapsed, start + 1);
  const progress = next ? Math.max(0, Math.min(1, (elapsed - start) / (end - start))) : 1;
  return { elapsed: elapsed, unlocked: unlocked, next: next, prev: prev, progress: progress };
}

function achievementDesc(a) {
  const text = a.desc[state.lang];
  return a.type === "money" ? text.replace("{amount}", fmtMoney(a.value)) : text;
}

function getUnlockedAchievements() {
  const set = new Set(state.unlocked);
  return ACHIEVEMENTS.filter(function (a) { return set.has(a.id); });
}

function getLockedAchievements() {
  const set = new Set(state.unlocked);
  return ACHIEVEMENTS.filter(function (a) { return !set.has(a.id); });
}

function isAchievementUnlocked(a) {
  if (state.unlocked.indexOf(a.id) !== -1) return true;
  if (a.type === "time") return getElapsedSec() >= a.value;
  if (a.type === "money") return getSavedTotal() >= a.value;
  if (a.type === "slip") return state.slips > 0;
  return false;
}

function syncUnlocked(withToast) {
  const newly = [];
  ACHIEVEMENTS.forEach(function (a) {
    if (state.unlocked.indexOf(a.id) !== -1) return;
    if (isAchievementUnlocked(a)) {
      state.unlocked.push(a.id);
      newly.push(a);
    }
  });
  if (newly.length && withToast) {
    const last = newly[newly.length - 1];
    showToast(t("newAchievement") + ": " + last.title[state.lang]);
  }
  return newly;
}

function formatConsumption() {
  const p = getProduct();
  if (p.perWeek) {
    const sessions = state.unitsPerDay * 7;
    return fmtNumber(sessions, 1) + " " + unitWord(sessions, p) + " " + t("perWeekShort");
  }
  return fmtNumber(state.unitsPerDay, 1) + " " + unitWord(state.unitsPerDay, p);
}

function formatPrice() {
  const p = getProduct();
  if (p.perWeek) {
    return fmtMoney(state.pricePerPackage) + (state.lang === "ru" ? " · за сессию" : " · per session");
  }
  return fmtMoney(state.pricePerPackage) + " · " + fmtNumber(state.unitsPerPackage) + " " + unitWord(state.unitsPerPackage, p);
}

function formatAvoided() {
  const p = getProduct();
  const total = Math.floor(getAvoidedTotal());
  return fmtNumber(total) + " " + unitWord(total, p);
}

function formatProfileSub() {
  return getCurrentDays() + " " + pluralDays(getCurrentDays()) + " " + t("profileSub");
}

function calculateOnboardingCost() {
  const p = PRODUCTS[onboarding.product] || PRODUCTS.cigarettes;
  const units = Number(onboarding.units) || 0;
  const price = Number(onboarding.price) || 0;
  const pack = Number(onboarding.pack) || 1;
  if (p.perWeek) return price * (units / 7);
  return (price / Math.max(1, pack)) * units;
}

/* ---------------- Preferences ---------------- */
function savePrefs() {
  try {
    localStorage.setItem(PREFS_KEY, JSON.stringify({ lang: state.lang, theme: state.theme }));
  } catch (e) { /* file:// or private mode */ }
}

function loadPrefs() {
  try {
    const raw = localStorage.getItem(PREFS_KEY);
    if (!raw) return;
    const prefs = JSON.parse(raw);
    if (prefs.lang === "ru" || prefs.lang === "en") state.lang = prefs.lang;
    if (prefs.theme === "light" || prefs.theme === "dark" || prefs.theme === "system") state.theme = prefs.theme;
  } catch (e) { /* ignore */ }
}

function resolvedTheme() {
  if (state.theme === "system") {
    return window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
  }
  return state.theme;
}

function applyTheme() {
  document.documentElement.dataset.theme = resolvedTheme();
  document.documentElement.lang = state.lang;
}

/* ---------------- Actions ---------------- */
function setLang(lang) {
  if (lang !== "ru" && lang !== "en") return;
  state.lang = lang;
  applyTheme();
  savePrefs();
  renderAll();
}

function setTheme(mode) {
  if (["light", "dark", "system"].indexOf(mode) === -1) return;
  state.theme = mode;
  applyTheme();
  savePrefs();
  renderAll();
}

function setCurrency(code) {
  if (!CURRENCIES[code]) return;
  state.currency = code;
  closeSheet();
  renderAll();
  showToast(t("currencyChanged"));
}

function formatCurrencyValue() {
  const c = CURRENCIES[state.currency] || CURRENCIES.RUB;
  return c.symbol + " " + c.code;
}

function switchTab(tab) {
  if (["home", "timeline", "progress", "settings"].indexOf(tab) === -1) return;
  ui.screen = tab;
  document.querySelectorAll(".screen").forEach(function (el) {
    el.classList.toggle("is-active", el.dataset.screen === tab);
  });
  renderTabs();
  renderScreen(tab);
  updateLive();
  const el = document.getElementById("screen-" + tab);
  if (el) el.scrollTop = 0;
}

function showToast(message, actionLabel, actionFn) {
  ui.toast = { message: message, actionLabel: actionLabel || null, action: actionFn || null };
  if (ui.toastTimer) clearTimeout(ui.toastTimer);
  renderToast();
  ui.toastTimer = setTimeout(function () {
    ui.toast = null;
    renderToast();
  }, 6000);
}

function openOnboarding(mode) {
  onboarding.mode = mode === "edit" ? "edit" : "new";
  onboarding.open = true;
  onboarding.step = onboarding.mode === "edit" ? 2 : 1;
  onboarding.notifications = state.notifications;
  onboarding.currency = state.currency;

  if (onboarding.mode === "edit") {
    const p = getProduct();
    onboarding.product = state.product;
    onboarding.quitDate = state.quitDate;
    onboarding.units = p.perWeek ? Math.round(state.unitsPerDay * 7 * 10) / 10 : state.unitsPerDay;
    onboarding.price = state.pricePerPackage;
    onboarding.pack = state.unitsPerPackage;
  } else {
    const p = PRODUCTS.cigarettes;
    onboarding.product = "cigarettes";
    onboarding.quitDate = Date.now();
    onboarding.units = p.defaults.units;
    onboarding.price = p.defaults.price;
    onboarding.pack = p.defaults.pack;
  }

  closeSheet();
  renderAll();
}

function closeOnboarding() {
  onboarding.open = false;
  renderAll();
}

function onboardingSetProduct(id) {
  if (!PRODUCTS[id]) return;
  onboarding.product = id;
  const p = PRODUCTS[id];
  onboarding.units = p.defaults.units;
  onboarding.price = p.defaults.price;
  onboarding.pack = p.defaults.pack;
  renderOnboarding();
}

function onboardingSetCurrency(code) {
  if (!CURRENCIES[code]) return;
  onboarding.currency = code;
  renderOnboarding();
}

function onboardingQuick(days) {
  onboarding.quitDate = Date.now() - Math.max(0, days) * DAY * 1000;
  renderOnboarding();
}

function onboardingNext() {
  if (onboarding.step === 3) {
    const ts = onboarding.quitDate;
    if (!Number.isFinite(ts) || ts > Date.now()) {
      showToast(t("obNoteDate"));
      return;
    }
  }
  if (onboarding.step === 4) {
    if (!(Number(onboarding.units) > 0) || !(Number(onboarding.price) > 0) || !(Number(onboarding.pack) > 0)) {
      showToast(t("obErrorMoney"));
      return;
    }
  }
  if (onboarding.step >= 5) {
    finishOnboarding();
    return;
  }
  onboarding.step += 1;
  renderOnboarding();
}

function onboardingBack() {
  if (onboarding.step <= 1) return;
  onboarding.step -= 1;
  renderOnboarding();
}

function finishOnboarding() {
  const p = PRODUCTS[onboarding.product] || PRODUCTS.cigarettes;
  const ts = Math.min(onboarding.quitDate, Date.now());
  const units = Math.max(0.01, Number(onboarding.units) || 1);
  const price = Math.max(0, Number(onboarding.price) || 0);
  const pack = p.packLabel ? Math.max(1, Number(onboarding.pack) || 1) : 1;
  const currency = CURRENCIES[onboarding.currency] ? onboarding.currency : "RUB";
  const unitsPerDay = p.perWeek ? units / 7 : units;
  const unitsPerPackage = p.perWeek ? 1 : pack;

  state.currency = currency;

  if (onboarding.mode === "edit") {
    state.quitDate = ts;
    state.product = p.id;
    state.unitsPerDay = unitsPerDay;
    state.pricePerPackage = price;
    state.unitsPerPackage = unitsPerPackage;
    state.notifications = onboarding.notifications;
    state.savedBase = (state.priorCleanSec / DAY) * getCostPerDay();
    state.avoidedBase = (state.priorCleanSec / DAY) * state.unitsPerDay;
  } else {
    state.quitDate = ts;
    state.product = p.id;
    state.unitsPerDay = unitsPerDay;
    state.pricePerPackage = price;
    state.unitsPerPackage = unitsPerPackage;
    state.notifications = onboarding.notifications;
    state.priorCleanSec = 0;
    state.bestStreakSec = 0;
    state.savedBase = 0;
    state.avoidedBase = 0;
    state.slips = 0;
    state.unlocked = [];
  }

  const wasEdit = onboarding.mode === "edit";
  onboarding.open = false;
  syncUnlocked(false);
  renderAll();
  switchTab("home");
  showToast(t(wasEdit ? "planUpdated" : "journeyStarted"));
}

function commitSlip() {
  const snapshot = JSON.parse(JSON.stringify(state));
  const elapsed = getElapsedSec();
  if (elapsed <= 0) {
    closeSheet();
    return;
  }

  state.priorCleanSec += elapsed;
  state.bestStreakSec = Math.max(state.bestStreakSec, elapsed);
  state.savedBase += getCostPerDay() * (elapsed / DAY);
  state.avoidedBase += state.unitsPerDay * (elapsed / DAY);
  state.slips += 1;
  state.quitDate = Date.now();
  if (state.unlocked.indexOf("slip") === -1) state.unlocked.push("slip");

  ui.slipSnapshot = snapshot;
  syncUnlocked(false);
  closeSheet();
  renderAll();
  switchTab("home");
  showToast(t("slipToast"), t("undo"), undoSlip);
}

function undoSlip() {
  if (!ui.slipSnapshot) return;
  const snapshot = ui.slipSnapshot;
  ui.slipSnapshot = null;
  Object.assign(state, snapshot);
  renderAll();
  switchTab("home");
  showToast(t("slipUndone"));
}

function resetDemo() {
  const lang = state.lang;
  const theme = state.theme;
  Object.assign(state, demoState());
  state.lang = lang;
  state.theme = theme;
  ui.screen = "home";
  ui.slipSnapshot = null;
  onboarding.open = false;
  closeSheet();
  syncUnlocked(false);
  renderAll();
  switchTab("home");
  showToast(t("demoReset"));
}

function resetAll() {
  const lang = state.lang;
  const theme = state.theme;
  Object.assign(state, demoState());
  state.lang = lang;
  state.theme = theme;
  state.quitDate = Date.now();
  state.unitsPerDay = 20;
  state.pricePerPackage = 250;
  state.unitsPerPackage = 20;
  state.product = "cigarettes";
  state.priorCleanSec = 0;
  state.bestStreakSec = 0;
  state.savedBase = 0;
  state.avoidedBase = 0;
  state.slips = 0;
  state.notifications = true;
  state.unlocked = [];
  ui.screen = "home";
  ui.slipSnapshot = null;
  closeSheet();
  syncUnlocked(false);
  renderAll();
  openOnboarding("new");
  showToast(t("resetToast"));
}

function toggleNotifications() {
  state.notifications = !state.notifications;
  renderScreen(ui.screen);
}

function exportData() {
  const p = getProduct();
  const data = {
    app: "Не курю / I Quit",
    exportedAt: new Date().toISOString(),
    quitDate: new Date(state.quitDate).toISOString(),
    product: p.id,
    productLabel: p.name[state.lang],
    unitsPerDay: Math.round(state.unitsPerDay * 100) / 100,
    pricePerPackage: state.pricePerPackage,
    unitsPerPackage: state.unitsPerPackage,
    currency: state.currency,
    currentStreakSeconds: Math.floor(getElapsedSec()),
    bestStreakSeconds: Math.floor(getBestSec()),
    totalCleanSeconds: Math.floor(getTotalCleanSec()),
    slips: state.slips,
    moneySaved: Math.round(getSavedTotal()),
    avoidedUnits: Math.round(getAvoidedTotal()),
    achievements: state.unlocked.slice(),
    notifications: state.notifications
  };
  const blob = new Blob([JSON.stringify(data, null, 2)], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = "i-quit-data.json";
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
  showToast(t("exportToast"));
}

/* ---------------- Onboarding input ---------------- */
function updateOnboardingField(field, value) {
  if (field === "units") onboarding.units = Number(value) || 0;
  if (field === "price") onboarding.price = Number(value) || 0;
  if (field === "pack") onboarding.pack = Number(value) || 0;
  if (field === "date") {
    const ts = fromLocalInput(value);
    if (ts != null) onboarding.quitDate = ts;
  }
  const costEl = document.querySelector("[data-ob-cost]");
  if (costEl) costEl.textContent = fmtMoney(calculateOnboardingCost(), onboarding.currency);
}
