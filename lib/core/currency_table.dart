// ISO 4217 currencies (IRR and USD are defined in code, see money.dart).
// Format per line:
//   CODE|minor digits|symbol (empty = use code)|English name|Persian name|short Persian name (optional)
const kCurrencyTable = r'''
EUR|2|€|Euro|یورو
GBP|2|£|British Pound|پوند انگلیس|پوند
AED|2||UAE Dirham|درهم امارات|درهم
TRY|2|₺|Turkish Lira|لیر ترکیه|لیر
CAD|2|CA$|Canadian Dollar|دلار کانادا
AUD|2|A$|Australian Dollar|دلار استرالیا
NZD|2|NZ$|New Zealand Dollar|دلار نیوزیلند
CHF|2||Swiss Franc|فرانک سوئیس
SEK|2||Swedish Krona|کرون سوئد
NOK|2||Norwegian Krone|کرون نروژ
DKK|2||Danish Krone|کرون دانمارک
ISK|0||Icelandic Króna|کرون ایسلند
CZK|2||Czech Koruna|کرون چک
PLN|2||Polish Złoty|زلوتی لهستان
HUF|2||Hungarian Forint|فورینت مجارستان
RON|2||Romanian Leu|لئوی رومانی
BGN|2||Bulgarian Lev|لف بلغارستان
RSD|2||Serbian Dinar|دینار صربستان
UAH|2|₴|Ukrainian Hryvnia|گریونا اوکراین
RUB|2|₽|Russian Ruble|روبل روسیه
BYN|2||Belarusian Ruble|روبل بلاروس
MDL|2||Moldovan Leu|لئوی مولداوی
ALL|2||Albanian Lek|لک آلبانی
MKD|2||Macedonian Denar|دینار مقدونیه
BAM|2||Bosnia-Herzegovina Convertible Mark|مارک تبدیل‌پذیر بوسنی
GEL|2|₾|Georgian Lari|لاری گرجستان
AMD|2||Armenian Dram|درام ارمنستان
AZN|2||Azerbaijani Manat|منات آذربایجان
KZT|2|₸|Kazakhstani Tenge|تنگه قزاقستان
UZS|2||Uzbekistani Som|سوم ازبکستان
KGS|2||Kyrgyzstani Som|سوم قرقیزستان
TJS|2||Tajikistani Somoni|سامانی تاجیکستان
TMT|2||Turkmenistani Manat|منات ترکمنستان
AFN|2||Afghan Afghani|افغانی افغانستان
PKR|2||Pakistani Rupee|روپیه پاکستان
INR|2|₹|Indian Rupee|روپیه هند
LKR|2||Sri Lankan Rupee|روپیه سریلانکا
NPR|2||Nepalese Rupee|روپیه نپال
BDT|2||Bangladeshi Taka|تاکا بنگلادش
BTN|2||Bhutanese Ngultrum|انگولتروم بوتان
MVR|2||Maldivian Rufiyaa|روفیه مالدیو
CNY|2|CN¥|Chinese Yuan|یوان چین
HKD|2|HK$|Hong Kong Dollar|دلار هنگ‌کنگ
MOP|2||Macanese Pataca|پاتاکای ماکائو
TWD|2|NT$|New Taiwan Dollar|دلار تایوان
JPY|0|¥|Japanese Yen|ین ژاپن
KRW|0|₩|South Korean Won|وون کره جنوبی
MNT|2||Mongolian Tögrög|توگریک مغولستان
SGD|2|S$|Singapore Dollar|دلار سنگاپور
MYR|2||Malaysian Ringgit|رینگیت مالزی
THB|2|฿|Thai Baht|بات تایلند
IDR|2||Indonesian Rupiah|روپیه اندونزی
PHP|2|₱|Philippine Peso|پزوی فیلیپین
VND|0|₫|Vietnamese Dong|دانگ ویتنام
KHR|2||Cambodian Riel|ریل کامبوج
LAK|2||Lao Kip|کیپ لائوس
MMK|2||Myanmar Kyat|کیات میانمار
BND|2||Brunei Dollar|دلار برونئی
SAR|2||Saudi Riyal|ریال عربستان
QAR|2||Qatari Riyal|ریال قطر
KWD|3||Kuwaiti Dinar|دینار کویت
BHD|3||Bahraini Dinar|دینار بحرین
OMR|3||Omani Rial|ریال عمان
JOD|3||Jordanian Dinar|دینار اردن
IQD|3||Iraqi Dinar|دینار عراق
ILS|2|₪|Israeli New Shekel|شیکل اسرائیل
LBP|2||Lebanese Pound|لیر لبنان
SYP|2||Syrian Pound|لیر سوریه
YER|2||Yemeni Rial|ریال یمن
EGP|2||Egyptian Pound|پوند مصر
LYD|3||Libyan Dinar|دینار لیبی
TND|3||Tunisian Dinar|دینار تونس
DZD|2||Algerian Dinar|دینار الجزایر
MAD|2||Moroccan Dirham|درهم مراکش
SDG|2||Sudanese Pound|پوند سودان
ETB|2||Ethiopian Birr|بیر اتیوپی
KES|2||Kenyan Shilling|شیلینگ کنیا
UGX|0||Ugandan Shilling|شیلینگ اوگاندا
TZS|2||Tanzanian Shilling|شیلینگ تانزانیا
RWF|0||Rwandan Franc|فرانک رواندا
NGN|2|₦|Nigerian Naira|نایرا نیجریه
GHS|2||Ghanaian Cedi|سدی غنا
ZAR|2||South African Rand|راند آفریقای جنوبی
XOF|0||West African CFA Franc|فرانک غرب آفریقا
XAF|0||Central African CFA Franc|فرانک آفریقای مرکزی
ZMW|2||Zambian Kwacha|کواچای زامبیا
MZN|2||Mozambican Metical|متیکال موزامبیک
AOA|2||Angolan Kwanza|کوانزای آنگولا
BWP|2||Botswana Pula|پولا بوتسوانا
NAD|2||Namibian Dollar|دلار نامیبیا
MUR|2||Mauritian Rupee|روپیه موریس
SCR|2||Seychellois Rupee|روپیه سیشل
MGA|2||Malagasy Ariary|آریاری ماداگاسکار
CDF|2||Congolese Franc|فرانک کنگو
MXN|2|MX$|Mexican Peso|پزوی مکزیک
BRL|2|R$|Brazilian Real|رئال برزیل
ARS|2||Argentine Peso|پزوی آرژانتین
CLP|0||Chilean Peso|پزوی شیلی
COP|2||Colombian Peso|پزوی کلمبیا
PEN|2||Peruvian Sol|سول پرو
UYU|2||Uruguayan Peso|پزوی اروگوئه
BOB|2||Bolivian Boliviano|بولیویانوی بولیوی
PYG|0||Paraguayan Guaraní|گوارانی پاراگوئه
VES|2||Venezuelan Bolívar|بولیوار ونزوئلا
DOP|2||Dominican Peso|پزوی دومینیکن
CRC|2||Costa Rican Colón|کولون کاستاریکا
GTQ|2||Guatemalan Quetzal|کتسال گواتمالا
HNL|2||Honduran Lempira|لمپیرا هندوراس
NIO|2||Nicaraguan Córdoba|کوردوبا نیکاراگوئه
PAB|2||Panamanian Balboa|بالبوآ پاناما
JMD|2||Jamaican Dollar|دلار جامائیکا
TTD|2||Trinidad & Tobago Dollar|دلار ترینیداد و توباگو
BSD|2||Bahamian Dollar|دلار باهاما
BBD|2||Barbadian Dollar|دلار باربادوس
CUP|2||Cuban Peso|پزوی کوبا
HTG|2||Haitian Gourde|گورد هائیتی
XCD|2||East Caribbean Dollar|دلار شرق کارائیب
KYD|2||Cayman Islands Dollar|دلار جزایر کیمن
BMD|2||Bermudian Dollar|دلار برمودا
AWG|2||Aruban Florin|فلورین آروبا
BZD|2||Belize Dollar|دلار بلیز
GYD|2||Guyanese Dollar|دلار گویان
SRD|2||Surinamese Dollar|دلار سورینام
FJD|2||Fijian Dollar|دلار فیجی
PGK|2||Papua New Guinean Kina|کینای پاپوآ گینه نو
XPF|0||CFP Franc|فرانک اقیانوسیه (CFP)
WST|2||Samoan Tala|تالای ساموآ
TOP|2||Tongan Paʻanga|پاآنگای تونگا
VUV|0||Vanuatu Vatu|واتوی وانواتو
SBD|2||Solomon Islands Dollar|دلار جزایر سلیمان
CVE|2||Cape Verdean Escudo|اسکودوی کیپ‌ورد
GMD|2||Gambian Dalasi|دالاسی گامبیا
SLE|2||Sierra Leonean Leone|لئون سیرالئون
LRD|2||Liberian Dollar|دلار لیبریا
GNF|0||Guinean Franc|فرانک گینه
MWK|2||Malawian Kwacha|کواچای مالاوی
SZL|2||Swazi Lilangeni|لیلانگنی اسواتینی
LSL|2||Lesotho Loti|لوتی لسوتو
BIF|0||Burundian Franc|فرانک بوروندی
DJF|0||Djiboutian Franc|فرانک جیبوتی
SOS|2||Somali Shilling|شیلینگ سومالی
ERN|2||Eritrean Nakfa|ناکفای اریتره
MRU|2||Mauritanian Ouguiya|اوگیای موریتانی
STN|2||São Tomé & Príncipe Dobra|دوبرای سائوتومه و پرینسیپ
KMF|0||Comorian Franc|فرانک کومور
''';
