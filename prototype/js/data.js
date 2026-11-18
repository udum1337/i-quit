/* ============================================================
   Static content: icons, products, health milestones, achievements
   ============================================================ */

const ICONS = {
  logo: '<path d="M12 21c0-5 3-8 8-9-1 5-4 8-8 9Z" fill="currentColor" stroke="none"/><path d="M4 20c0-7 4-12 11-14 0 9-5 14-11 14Z" fill="currentColor" stroke="none" opacity=".7"/>',
  home: '<path d="M3.5 10.5 12 3l8.5 7.5"/><path d="M5.5 9.5V20h13V9.5"/><path d="M9.5 20v-6h5v6"/>',
  timeline: '<circle cx="12" cy="12" r="8.5"/><path d="M12 7.5V12l3 2"/>',
  chart: '<path d="M4 19V5"/><path d="M4 19h16"/><path d="M7.5 15.5v-3M11.5 15.5V9M15.5 15.5v-5M19.5 15.5V7"/>',
  settings: '<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .34 1.87l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.7 1.7 0 0 0-1.87-.34 1.7 1.7 0 0 0-1 1.55V21a2 2 0 1 1-4 0v-.09a1.7 1.7 0 0 0-1-1.55 1.7 1.7 0 0 0-1.87.34l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.7 1.7 0 0 0 .34-1.87 1.7 1.7 0 0 0-1.55-1H3a2 2 0 1 1 0-4h.09a1.7 1.7 0 0 0 1.55-1 1.7 1.7 0 0 0-.34-1.87l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.7 1.7 0 0 0 1.87.34h.01a1.7 1.7 0 0 0 1-1.55V3a2 2 0 1 1 4 0v.09a1.7 1.7 0 0 0 1 1.55 1.7 1.7 0 0 0 1.87-.34l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.7 1.7 0 0 0-.34 1.87v.01a1.7 1.7 0 0 0 1.55 1H21a2 2 0 1 1 0 4h-.09a1.7 1.7 0 0 0-1.55 1Z"/>',
  heart: '<path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1.1-1.1a5.5 5.5 0 0 0-7.8 7.8l1.1 1.1L12 21l7.8-7.5 1.1-1.1a5.5 5.5 0 0 0-.1-7.8Z"/>',
  wind: '<path d="M3 8h11a3 3 0 1 0-3-3"/><path d="M3 12h15a3 3 0 1 1-3 3"/><path d="M3 16h7"/>',
  lungs: '<path d="M12 3v7"/><path d="M9 7c0 0-1.5 2-3.5 2S3 11 3 13.5V17a3 3 0 0 0 3 3h1a2 2 0 0 0 2-2V9"/><path d="M15 7c0 0 1.5 2 3.5 2S21 11 21 13.5V17a3 3 0 0 1-3 3h-1a2 2 0 0 1-2-2V9"/>',
  sun: '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>',
  leaf: '<path d="M20 4C12 4 5 8 4 16c0 0 2 4 5 4 8-1 11-8 11-16Z"/><path d="M4 20c3-6 7-9 12-11"/>',
  calendar: '<rect x="3" y="5" width="18" height="16" rx="3"/><path d="M7 3v4M17 3v4M3 10h18"/><path d="M8 14h2M14 14h2M8 17.5h2M14 17.5h2"/>',
  trophy: '<path d="M8 4h8v5a4 4 0 0 1-8 0V4Z"/><path d="M8 6H4.5v1.5A3.5 3.5 0 0 0 8 11M16 6h3.5v1.5A3.5 3.5 0 0 1 16 11"/><path d="M12 13v4M8.5 21h7M10 17h4"/>',
  flame: '<path d="M12 22c4 0 7-2.7 7-6.5 0-3.2-2-5.5-4-7.5-.8 2-2 3-3 3.5.3-3-1-6-3-8-.3 3.5-4 6.5-4 12C5 19.3 8 22 12 22Z"/>',
  shield: '<path d="M12 3 4.5 6v5.5c0 4.5 3 8 7.5 9.5 4.5-1.5 7.5-5 7.5-9.5V6L12 3Z"/><path d="m9 12 2 2 4-4"/>',
  star: '<path d="m12 3 2.8 5.7 6.2.9-4.5 4.4 1.1 6.2-5.6-3-5.6 3 1.1-6.2L3 9.6l6.2-.9L12 3Z"/>',
  award: '<circle cx="12" cy="9" r="5.5"/><path d="m8.5 13.5-1 8 4.5-2.5 4.5 2.5-1-8"/>',
  coin: '<circle cx="12" cy="12" r="8.5"/><path d="M12 7v10M9.5 9.5c0-1 1-1.8 2.5-1.8s2.5.8 2.5 1.8-1 1.7-2.5 2-2.5 1-2.5 2 1 1.8 2.5 1.8 2.5-.8 2.5-1.8"/>',
  banknote: '<rect x="2.5" y="6" width="19" height="12" rx="2.5"/><circle cx="12" cy="12" r="2.5"/><path d="M6 9.5h.01M18 14.5h.01"/>',
  bell: '<path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9Z"/><path d="M10 21h4"/>',
  moon: '<path d="M21 12.8A8.5 8.5 0 1 1 11.2 3 7 7 0 0 0 21 12.8Z"/>',
  globe: '<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c2.5 2.5 2.5 15 0 18M12 3c-2.5 2.5-2.5 15 0 18"/>',
  info: '<circle cx="12" cy="12" r="9"/><path d="M12 11v6M12 7.5h.01"/>',
  download: '<path d="M12 3v12M7.5 10.5 12 15l4.5-4.5"/><path d="M4 19h16"/>',
  trash: '<path d="M4 7h16M9 7V4h6v3M6.5 7l1 14h9l1-14"/><path d="M10 11v6M14 11v6"/>',
  chevron: '<path d="m9 5 7 7-7 7"/>',
  check: '<path d="m4 12.5 5 5L20 6.5"/>',
  close: '<path d="M6 6l12 12M18 6 6 18"/>',
  back: '<path d="m15 5-7 7 7 7"/>',
  sparkles: '<path d="m12 3 1.2 4.3L17.5 8.5l-4.3 1.2L12 14l-1.2-4.3L6.5 8.5l4.3-1.2L12 3Z"/><path d="m19 14 .7 2.3L22 17l-2.3.7L19 20l-.7-2.3L16 17l2.3-.7L19 14Z"/><path d="m5 13 .6 1.9L7.5 15.5l-1.9.6L5 18l-.6-1.9L2.5 15.5l1.9-.6L5 13Z"/>',
  droplet: '<path d="M12 3s6 6.5 6 11a6 6 0 0 1-12 0c0-4.5 6-11 6-11Z"/>',
  activity: '<path d="M3 12h4l2.5-6 4 12L16 12h5"/>',
  clock: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3.5 2"/>',
  lock: '<rect x="4.5" y="10" width="15" height="10" rx="2.5"/><path d="M8 10V7a4 4 0 0 1 8 0v3"/>',
  arrow: '<path d="M7 17 17 7M9 7h8v8"/>',
  refresh: '<path d="M20 11a8 8 0 1 0-2.3 6.3"/><path d="M20 4v7h-7"/>',
  target: '<circle cx="12" cy="12" r="8.5"/><circle cx="12" cy="12" r="4.5"/><circle cx="12" cy="12" r=".8" fill="currentColor"/>',
  cigarette: '<rect x="2.5" y="13" width="15" height="5.5" rx="1.2"/><path d="M6 13v5.5M17.5 15.7h2.5"/><path d="M18 10.5c0-1.5 1-2 1-3.5M15 10.5c0-1.5 1-2 1-3.5" opacity=".55"/>',
  vape: '<rect x="8" y="3" width="8" height="13" rx="2"/><path d="M11 16v4M9.5 8h5"/><path d="M18 10c0-1.5 1-2 1-3.5M18 14c0-1.5 1-2 1-3.5" opacity=".55"/>',
  iqos: '<rect x="6" y="9" width="12" height="11" rx="2"/><rect x="9" y="3" width="6" height="8" rx="1"/><path d="M9 14h6M9 17h4"/>',
  hookah: '<path d="M9 4h6v3H9z"/><path d="M12 7v5"/><path d="M7 12h10l-1 7H8l-1-7Z"/><path d="M17 13c3 1 3 4 1 5"/>',
  snus: '<circle cx="12" cy="12" r="8.5"/><circle cx="12" cy="12" r="5"/><path d="M8 9.5c1.5-1 6.5-1 8 .5"/>',
  noSmoke: '<path d="M3 3l18 18"/><rect x="3" y="13" width="13" height="5" rx="1.2"/><path d="M19 15h2"/><path d="M17 9c0-1.5 1-2 1-3.5M14 9c0-1.5 1-2 1-3.5" opacity=".5"/>',
  play: '<path d="M8 5v14l11-7-11-7Z" fill="currentColor" stroke="none"/>'
};

const PRODUCTS = {
  cigarettes: {
    id: 'cigarettes', icon: 'cigarette',
    name: { ru: 'Сигареты', en: 'Cigarettes' },
    unit: { ru: 'сигарет в день', en: 'cigarettes per day' },
    unitShort: { ru: 'сигарет', en: 'cigarettes' },
    unitForms: {
      ru: { one: 'сигарета', few: 'сигареты', many: 'сигарет' },
      en: { one: 'cigarette', many: 'cigarettes' }
    },
    priceLabel: { ru: 'Цена пачки', en: 'Pack price' },
    packLabel: { ru: 'Сигарет в пачке', en: 'Cigarettes per pack' },
    defaults: { units: 20, price: 250, pack: 20 }, perWeek: false
  },
  vape: {
    id: 'vape', icon: 'vape',
    name: { ru: 'Вейп', en: 'Vape' },
    unit: { ru: 'мл в день', en: 'ml per day' },
    unitShort: { ru: 'мл', en: 'ml' },
    unitForms: {
      ru: { one: 'мл', few: 'мл', many: 'мл' },
      en: { one: 'ml', many: 'ml' }
    },
    priceLabel: { ru: 'Цена бутылки', en: 'Bottle price' },
    packLabel: { ru: 'Мл в бутылке', en: 'Ml per bottle' },
    defaults: { units: 3, price: 900, pack: 30 }, perWeek: false
  },
  iqos: {
    id: 'iqos', icon: 'iqos',
    name: { ru: 'IQOS / стики', en: 'IQOS / heated' },
    unit: { ru: 'стиков в день', en: 'sticks per day' },
    unitShort: { ru: 'стиков', en: 'sticks' },
    unitForms: {
      ru: { one: 'стик', few: 'стика', many: 'стиков' },
      en: { one: 'stick', many: 'sticks' }
    },
    priceLabel: { ru: 'Цена пачки', en: 'Pack price' },
    packLabel: { ru: 'Стиков в пачке', en: 'Sticks per pack' },
    defaults: { units: 15, price: 200, pack: 20 }, perWeek: false
  },
  hookah: {
    id: 'hookah', icon: 'hookah',
    name: { ru: 'Кальян', en: 'Hookah' },
    unit: { ru: 'сессий в неделю', en: 'sessions per week' },
    unitShort: { ru: 'сессий', en: 'sessions' },
    unitForms: {
      ru: { one: 'сессия', few: 'сессии', many: 'сессий' },
      en: { one: 'session', many: 'sessions' }
    },
    priceLabel: { ru: 'Цена сессии', en: 'Cost per session' },
    packLabel: null,
    defaults: { units: 3, price: 500, pack: 1 }, perWeek: true
  },
  snus: {
    id: 'snus', icon: 'snus',
    name: { ru: 'Снюс / паучи', en: 'Snus / pouches' },
    unit: { ru: 'паучей в день', en: 'pouches per day' },
    unitShort: { ru: 'паучей', en: 'pouches' },
    unitForms: {
      ru: { one: 'пауч', few: 'пауча', many: 'паучей' },
      en: { one: 'pouch', many: 'pouches' }
    },
    priceLabel: { ru: 'Цена банки', en: 'Can price' },
    packLabel: { ru: 'Паучей в банке', en: 'Pouches per can' },
    defaults: { units: 8, price: 450, pack: 20 }, perWeek: false
  }
};

const CURRENCIES = {
  RUB: { code: 'RUB', symbol: '₽', label: { ru: 'Российский рубль', en: 'Russian ruble' } },
  USD: { code: 'USD', symbol: '$', label: { ru: 'Доллар США', en: 'US dollar' } },
  EUR: { code: 'EUR', symbol: '€', label: { ru: 'Евро', en: 'Euro' } },
  KZT: { code: 'KZT', symbol: '₸', label: { ru: 'Казахстанский тенге', en: 'Kazakhstani tenge' } },
  UAH: { code: 'UAH', symbol: '₴', label: { ru: 'Украинская гривна', en: 'Ukrainian hryvnia' } },
  BYN: { code: 'BYN', symbol: 'Br', label: { ru: 'Белорусский рубль', en: 'Belarusian ruble' } },
  GBP: { code: 'GBP', symbol: '£', label: { ru: 'Фунт стерлингов', en: 'British pound' } },
  TRY: { code: 'TRY', symbol: '₺', label: { ru: 'Турецкая лира', en: 'Turkish lira' } },
  CNY: { code: 'CNY', symbol: '¥', label: { ru: 'Китайский юань', en: 'Chinese yuan' } }
};
const CURRENCY_ORDER = ['RUB', 'USD', 'EUR', 'KZT', 'UAH', 'BYN', 'GBP', 'TRY', 'CNY'];

const SOURCES = {
  who: { org: 'WHO', title: { ru: 'Tobacco: health benefits of smoking cessation', en: 'Tobacco: health benefits of smoking cessation' }, url: 'https://www.who.int/news-room/questions-and-answers/item/tobacco-health-benefits-of-smoking-cessation' },
  cdc: { org: 'CDC', title: { ru: 'Benefits of Quitting Smoking', en: 'Benefits of Quitting Smoking' }, url: 'https://www.cdc.gov/tobacco/about/benefits-of-quitting.html' },
  nhs: { org: 'NHS', title: { ru: 'Quit smoking — Better Health', en: 'Quit smoking — Better Health' }, url: 'https://www.nhs.uk/better-health/quit-smoking/' },
  acs: { org: 'American Cancer Society', title: { ru: 'Health Benefits of Quitting Smoking Over Time', en: 'Health Benefits of Quitting Smoking Over Time' }, url: 'https://www.cancer.org/cancer/risk-prevention/tobacco/guide-quitting-smoking/benefits-of-quitting-smoking-over-time.html' },
  ala: { org: 'American Lung Association', title: { ru: 'Benefits of Quitting', en: 'Benefits of Quitting' }, url: 'https://www.lung.org/quit-smoking/i-want-to-quit/benefits-of-quitting' },
  cleveland: { org: 'Cleveland Clinic', title: { ru: 'What Happens to Your Body When You Quit Smoking?', en: 'What Happens to Your Body When You Quit Smoking?' }, url: 'https://health.clevelandclinic.org/happens-body-quit-smoking' },
  medline: { org: 'MedlinePlus', title: { ru: 'Benefits of quitting tobacco', en: 'Benefits of quitting tobacco' }, url: 'https://medlineplus.gov/ency/article/007532.htm' }
};

const D = 86400;
const MILESTONES = [
  {
    id: 'm20m', at: 20 * 60, group: 'hours', icon: 'heart',
    time: { ru: '20 минут', en: '20 minutes' },
    title: { ru: 'Пульс приходит в норму', en: 'Heart rate normalizes' },
    desc: { ru: 'Пульс и давление снижаются, кровоток в кистях и стопах улучшается.', en: 'Heart rate and blood pressure drop, and blood flow to hands and feet improves.' },
    long: { ru: 'Никотин сужает сосуды и заставляет сердце биться чаще. Уже через 20 минут после последней сигареты пульс и артериальное давление начинают снижаться, а сосуды постепенно расширяются.', en: 'Nicotine narrows blood vessels and makes your heart work harder. Within 20 minutes of your last cigarette, heart rate and blood pressure start to drop, and blood vessels begin to relax.' },
    sources: ['who', 'nhs', 'cleveland']
  },
  {
    id: 'm8h', at: 8 * 3600, group: 'hours', icon: 'wind',
    time: { ru: '8 часов', en: '8 hours' },
    title: { ru: 'Кислород возвращается', en: 'Oxygen levels rise' },
    desc: { ru: 'Угарный газ в крови снижается примерно вдвое, уровень кислорода растёт.', en: 'Carbon monoxide in your blood drops by about half, and oxygen levels rise.' },
    long: { ru: 'Угарный газ из дыма занимает место кислорода в крови. Через 8 часов его уровень снижается примерно вдвое, и тканям начинает доставаться больше кислорода.', en: 'Carbon monoxide from smoke takes the place of oxygen in your blood. After 8 hours, its level drops by about half, and your tissues get more oxygen.' },
    sources: ['nhs', 'cleveland']
  },
  {
    id: 'm12_24h', at: 12 * 3600, group: 'hours', icon: 'droplet',
    time: { ru: '12–24 часа', en: '12–24 hours' },
    title: { ru: 'Никотин покидает кровь', en: 'Nicotine leaves your blood' },
    desc: { ru: 'Угарный газ приходит к норме, никотин падает до нуля. Риск инфаркта начинает снижаться.', en: 'Carbon monoxide returns to normal and nicotine drops to zero. Heart attack risk starts to fall.' },
    long: { ru: 'Уровень угарного газа в крови возвращается к норме, а никотин практически полностью выводится. Одновременно начинает снижаться риск сердечного приступа.', en: 'Carbon monoxide levels return to normal, and nicotine is almost completely cleared. At the same time, your risk of a heart attack starts to decrease.' },
    sources: ['who', 'cdc', 'acs', 'ala']
  },
  {
    id: 'm48h', at: 48 * 3600, group: 'days', icon: 'leaf',
    time: { ru: '48 часов', en: '48 hours' },
    title: { ru: 'Лёгкие начинают очищаться', en: 'Your lungs start to clear' },
    desc: { ru: 'Организм выводит слизь и продукты горения. Вкус и запах становятся ярче.', en: 'Your body clears mucus and smoke residue. Taste and smell improve.' },
    long: { ru: 'Лёгкие начинают избавляться от слизи и продуктов горения. Восстанавливаются нервные окончания, поэтому вкус и запах ощущаются ярче.', en: 'Your lungs begin to clear mucus and smoke residue. Nerve endings start to recover, so taste and smell become more vivid.' },
    sources: ['nhs', 'cleveland']
  },
  {
    id: 'm72h', at: 72 * 3600, group: 'days', icon: 'lungs',
    time: { ru: '72 часа', en: '72 hours' },
    title: { ru: 'Дышать легче', en: 'Breathing gets easier' },
    desc: { ru: 'Бронхи расслабляются, дыхание становится свободнее, энергии больше.', en: 'Bronchial tubes relax, breathing feels easier, and energy levels rise.' },
    long: { ru: 'Бронхи расслабляются после постоянного раздражения дымом. Дыхание становится свободнее, а уровень энергии — выше.', en: 'Your bronchial tubes relax after constant irritation from smoke. Breathing feels easier, and energy levels increase.' },
    sources: ['nhs', 'cleveland']
  },
  {
    id: 'm2w', at: 14 * D, group: 'months', icon: 'activity',
    time: { ru: '2 недели', en: '2 weeks' },
    title: { ru: 'Кровообращение улучшается', en: 'Circulation improves' },
    desc: { ru: 'Кровообращение и функция лёгких улучшаются. Нагрузки переносятся легче.', en: 'Circulation and lung function improve. Physical activity feels easier.' },
    long: { ru: 'Кровообращение улучшается, а функция лёгких начинает расти. Ходьба и физические нагрузки переносятся заметно легче.', en: 'Circulation improves, and lung function begins to increase. Walking and physical activity feel noticeably easier.' },
    sources: ['who', 'ala', 'cleveland']
  },
  {
    id: 'm1m', at: 30 * D, group: 'months', icon: 'wind',
    time: { ru: '1 месяц', en: '1 month' },
    title: { ru: 'Кашель и одышка отступают', en: 'Cough and breathlessness ease' },
    desc: { ru: 'Кашель и одышка уменьшаются. Реснички в лёгких восстанавливаются.', en: 'Coughing and shortness of breath decrease. Cilia in your lungs recover.' },
    long: { ru: 'Кашель и одышка уменьшаются. Реснички в дыхательных путях восстанавливаются и снова помогают очищать лёгкие от слизи.', en: 'Coughing and shortness of breath decrease. Cilia in your airways recover and start helping clear mucus from your lungs again.' },
    sources: ['ala', 'medline', 'cleveland']
  },
  {
    id: 'm3m', at: 90 * D, group: 'months', icon: 'heart',
    time: { ru: '3 месяца', en: '3 months' },
    title: { ru: 'Риск инфаркта снижается', en: 'Heart attack risk drops' },
    desc: { ru: 'Риск инфаркта начинает снижаться, переносимость нагрузок растёт.', en: 'Heart attack risk starts to fall, and exercise tolerance improves.' },
    long: { ru: 'Риск сердечного приступа начинает снижаться, а переносимость физических нагрузок продолжает расти.', en: 'Your risk of a heart attack begins to decrease, and exercise tolerance continues to improve.' },
    sources: ['ala', 'cleveland']
  },
  {
    id: 'm9m', at: 270 * D, group: 'months', icon: 'shield',
    time: { ru: '9 месяцев', en: '9 months' },
    title: { ru: 'Реснички восстановились', en: 'Cilia have recovered' },
    desc: { ru: 'Реснички работают нормально: меньше кашля, слизи и инфекций.', en: 'Cilia work normally: less coughing, mucus, and infection.' },
    long: { ru: 'Реснички в лёгких снова работают нормально. Они выводят слизь и вместе с ней — часть бактерий и раздражителей, поэтому реже беспокоят кашель и инфекции.', en: 'Cilia in your lungs are working normally again. They move mucus — and some bacteria and irritants with it — out of your airways, so coughing and infections become less frequent.' },
    sources: ['ala', 'cleveland', 'medline']
  },
  {
    id: 'm1y', at: 365 * D, group: 'years', icon: 'star',
    time: { ru: '1 год', en: '1 year' },
    title: { ru: 'Сердце вдвое спокойнее', en: 'Heart risk halves' },
    desc: { ru: 'Добавочный риск ишемической болезни сердца вдвое ниже, чем у курящего.', en: 'Added risk of coronary heart disease is half that of someone who smokes.' },
    long: { ru: 'Добавочный риск ишемической болезни сердца становится вдвое ниже, чем у человека, который продолжает курить.', en: 'Your added risk of coronary heart disease is half that of someone who continues to smoke.' },
    sources: ['who', 'cdc', 'nhs']
  },
  {
    id: 'm2y', at: 2 * 365 * D, group: 'years', icon: 'activity',
    time: { ru: '2 года', en: '2 years' },
    title: { ru: 'Риск инфаркта падает резко', en: 'Heart attack risk drops sharply' },
    desc: { ru: 'Риск инфаркта снижается резко и продолжает падать дальше.', en: 'Heart attack risk drops sharply and continues to decline.' },
    long: { ru: 'Через 1–2 года после отказа риск сердечного приступа снижается резко. Дальше он продолжает уменьшаться постепенно.', en: 'One to two years after quitting, your risk of a heart attack drops sharply. After that, it continues to decline gradually.' },
    sources: ['cdc', 'acs']
  },
  {
    id: 'm3_6y', at: 3 * 365 * D, group: 'years', icon: 'shield',
    time: { ru: '3–6 лет', en: '3–6 years' },
    title: { ru: 'Коронарный риск снижается вдвое', en: 'Coronary risk halves' },
    desc: { ru: 'Добавочный риск ишемической болезни сердца снижается вдвое.', en: 'Added risk of coronary heart disease drops by half.' },
    long: { ru: 'Через 3–6 лет после отказа добавочный риск ишемической болезни сердца снижается вдвое по сравнению с продолжением курения.', en: 'Three to six years after quitting, your added risk of coronary heart disease is half what it would be if you kept smoking.' },
    sources: ['cdc']
  },
  {
    id: 'm5y', at: 5 * 365 * D, group: 'years', icon: 'trophy',
    time: { ru: '5 лет', en: '5 years' },
    title: { ru: 'Инсульт — как у некурящих', en: 'Stroke risk approaches normal' },
    desc: { ru: 'Риск инсульта приближается к норме. Риск рака полости рта и гортани ниже вдвое.', en: 'Stroke risk approaches normal. Mouth and throat cancer risk is cut in half.' },
    long: { ru: 'Риск инсульта приближается к уровню человека, который никогда не курил. Риск рака полости рта, глотки и гортани снижается примерно вдвое.', en: 'Stroke risk approaches that of someone who never smoked. Risk of mouth, throat, and voice box cancers is cut roughly in half.' },
    sources: ['who', 'ala', 'cdc']
  },
  {
    id: 'm10y', at: 10 * 365 * D, group: 'years', icon: 'lungs',
    time: { ru: '10 лет', en: '10 years' },
    title: { ru: 'Рак лёгких — вдвое ниже', en: 'Lung cancer risk halves' },
    desc: { ru: 'Риск смерти от рака лёгких вдвое ниже. Снижается риск рака мочевого пузыря и почек.', en: 'Lung cancer death risk is about half. Bladder and kidney cancer risks decrease.' },
    long: { ru: 'Риск смерти от рака лёгких примерно вдвое ниже, чем у продолжающего курить. Также снижается риск рака мочевого пузыря, пищевода и почек.', en: 'Your risk of dying from lung cancer is about half that of someone who keeps smoking. Risks of bladder, esophagus, and kidney cancer also decrease.' },
    sources: ['who', 'cdc', 'acs']
  },
  {
    id: 'm15y', at: 15 * 365 * D, group: 'years', icon: 'heart',
    time: { ru: '15 лет', en: '15 years' },
    title: { ru: 'Сердце как у некурящего', en: 'Heart like a non-smoker' },
    desc: { ru: 'Риск ишемической болезни сердца близок к уровню некурящих.', en: 'Coronary heart disease risk is close to that of a non-smoker.' },
    long: { ru: 'Риск ишемической болезни сердца становится близким к уровню человека, который никогда не курил.', en: 'Your risk of coronary heart disease becomes close to that of someone who never smoked.' },
    sources: ['cdc', 'who']
  },
  {
    id: 'm20y', at: 20 * 365 * D, group: 'years', icon: 'award',
    time: { ru: '20 лет', en: '20 years' },
    title: { ru: 'Риск рака — как у некурящих', en: 'Cancer risk approaches normal' },
    desc: { ru: 'Риск рака полости рта, гортани и поджелудочной близок к норме.', en: 'Mouth, throat, larynx, and pancreatic cancer risks approach normal.' },
    long: { ru: 'Риск рака полости рта, гортани, глотки и поджелудочной железы становится близким к уровню некурящих. Риск рака шейки матки снижается примерно вдвое.', en: 'Risk of mouth, throat, larynx, and pancreatic cancers becomes close to that of a non-smoker. Cervical cancer risk is about half.' },
    sources: ['cdc', 'acs']
  }
];

const ACHIEVEMENTS = [
  { id: 'a20m', type: 'time', value: 20 * 60, icon: 'sparkles', title: { ru: 'Первый шаг', en: 'First step' }, desc: { ru: '20 минут без никотина. Сердце уже чувствует разницу.', en: '20 minutes nicotine-free. Your heart already feels the difference.' } },
  { id: 'a8h', type: 'time', value: 8 * 3600, icon: 'wind', title: { ru: 'Кислород', en: 'Oxygen' }, desc: { ru: '8 часов без никотина. Кислород возвращается в кровь.', en: '8 hours nicotine-free. Oxygen is returning to your blood.' } },
  { id: 'a24h', type: 'time', value: 24 * 3600, icon: 'sun', title: { ru: 'Первые сутки', en: 'First day' }, desc: { ru: '24 часа без никотина. Никотин покидает кровь.', en: '24 hours nicotine-free. Nicotine is leaving your blood.' } },
  { id: 'a48h', type: 'time', value: 48 * 3600, icon: 'leaf', title: { ru: 'Вкус жизни', en: 'Taste of life' }, desc: { ru: '48 часов без никотина. Вкус и запах становятся ярче.', en: '48 hours nicotine-free. Taste and smell get brighter.' } },
  { id: 'a72h', type: 'time', value: 72 * 3600, icon: 'lungs', title: { ru: '72 часа', en: '72 hours' }, desc: { ru: 'Самые тяжёлые часы позади. Дышать легче.', en: 'The hardest hours are behind you. Breathing is easier.' } },
  { id: 'a1w', type: 'time', value: 7 * D, icon: 'calendar', title: { ru: 'Неделя', en: 'One week' }, desc: { ru: '7 дней без никотина. Привычка начинает меняться.', en: '7 days nicotine-free. The habit is starting to change.' } },
  { id: 'a2w', type: 'time', value: 14 * D, icon: 'activity', title: { ru: 'Две недели', en: 'Two weeks' }, desc: { ru: '14 дней без никотина. Кровообращение улучшается.', en: '14 days nicotine-free. Circulation is improving.' } },
  { id: 'a1m', type: 'time', value: 30 * D, icon: 'trophy', title: { ru: 'Месяц', en: 'One month' }, desc: { ru: '30 дней без никотина. Кашель и одышка отступают.', en: '30 days nicotine-free. Cough and breathlessness ease.' } },
  { id: 'a3m', type: 'time', value: 90 * D, icon: 'flame', title: { ru: 'Квартал', en: 'Three months' }, desc: { ru: '3 месяца без никотина. Риск инфаркта снижается.', en: '3 months nicotine-free. Heart attack risk is falling.' } },
  { id: 'a6m', type: 'time', value: 180 * D, icon: 'shield', title: { ru: 'Полгода', en: 'Six months' }, desc: { ru: '6 месяцев без никотина. Лёгкие работают лучше.', en: '6 months nicotine-free. Your lungs work better.' } },
  { id: 'a1y', type: 'time', value: 365 * D, icon: 'star', title: { ru: 'Год', en: 'One year' }, desc: { ru: 'Год без никотина. Риск болезней сердца вдвое ниже.', en: 'One year nicotine-free. Heart disease risk is halved.' } },
  { id: 'a5y', type: 'time', value: 5 * 365 * D, icon: 'award', title: { ru: 'Пять лет', en: 'Five years' }, desc: { ru: '5 лет без никотина. Риск инсульта приближается к норме.', en: '5 years nicotine-free. Stroke risk approaches normal.' } },
  { id: 'a10y', type: 'time', value: 10 * 365 * D, icon: 'heart', title: { ru: 'Десять лет', en: 'Ten years' }, desc: { ru: '10 лет без никотина. Риск рака лёгких вдвое ниже.', en: '10 years nicotine-free. Lung cancer risk is halved.' } },
  { id: 'money1k', type: 'money', value: 1000, icon: 'coin', title: { ru: 'Первая тысяча', en: 'First thousand' }, desc: { ru: 'Сэкономлено {amount}. Они остались с тобой.', en: '{amount} saved. It stays with you.' } },
  { id: 'money10k', type: 'money', value: 10000, icon: 'banknote', title: { ru: 'Десять тысяч', en: 'Ten thousand' }, desc: { ru: '{amount} остались с тобой.', en: '{amount} stays with you.' } },
  { id: 'money100k', type: 'money', value: 100000, icon: 'banknote', title: { ru: 'Сто тысяч', en: 'Hundred thousand' }, desc: { ru: '{amount} сэкономлено. Это уже на что-то большое.', en: '{amount} saved. That is something big.' } },
  { id: 'slip', type: 'slip', value: 1, icon: 'refresh', title: { ru: 'Пережил срыв', en: 'Survived a slip' }, desc: { ru: 'Срыв не отменяет путь. Ты вернулся — это главное.', en: 'A slip does not erase the journey. You came back — that is what matters.' } }
];

const ACHIEVEMENT_MAP = Object.fromEntries(ACHIEVEMENTS.map(a => [a.id, a]));
const MILESTONE_MAP = Object.fromEntries(MILESTONES.map(m => [m.id, m]));
