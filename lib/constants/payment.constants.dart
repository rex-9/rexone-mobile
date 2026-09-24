class BillingIntervals {
  const BillingIntervals._();

  static const day = 'day';
  static const week = 'week';
  static const month = 'month';
  static const year = 'year';

  static const all = <String>[day, week, month, year];
}

class CouponTypes {
  const CouponTypes._();

  static const percentage = 'percentage';
  static const fixed = 'fixed';
}

class PurchaseTypes {
  const PurchaseTypes._();

  static const trx = 'trx';
  static const sbs = 'sbs';
}

class PaymentCurrencies {
  const PaymentCurrencies._();

  static const usd = 'usd';
  static const mmk = 'mmk';
  static const sgd = 'sgd';
  static const all = <String>[usd, mmk, sgd];

  static const usdSymbol = r'$';
  static const mmkSymbol = 'MMK ';
  static const sgdSymbol = r'S$';
}

/// Official Stripe minimum charge amounts in minor currency units
/// Reference: https://docs.stripe.com/currencies#minimum-and-maximum-charge-amounts
class StripeMinimumAmounts {
  const StripeMinimumAmounts._();

  static const defaultLimit = 50;

  static const limits = <String, int>{
    'usd': 50, // $0.50 USD
    'sgd': 50, // $0.50 SGD
    'eur': 50, // €0.50 EUR
    'gbp': 30, // £0.30 GBP
    'aud': 50, // $0.50 AUD
    'cad': 50, // $0.50 CAD
    'chf': 50, // 0.50 CHF
    'jpy': 50, // ¥50 JPY
    'hkd': 400, // $4.00 HKD
    'myr': 200, // 2.00 MYR
    'thb': 1000, // 10.00 THB
    'nzd': 50, // $0.50 NZD
    'sek': 300, // 3.00 SEK
    'nok': 300, // 3.00 NOK
    'dkk': 250, // 2.50 DKK
    'pln': 200, // 2.00 PLN
    'inr': 50, // ₹0.50 INR
    'brl': 50, // R$0.50 BRL
    'mxn': 1000, // $10.00 MXN
    'aed': 200, // 2.00 AED
    'czk': 1500, // 15.00 CZK
    'huf': 17500, // 175.00 HUF
    'ron': 200, // 2.00 RON
    'bgn': 100, // 1.00 BGN
    'mmk': 50, // Fallback
  };

  static int getFor(String? currency) {
    if (currency == null) return defaultLimit;
    return limits[currency.toLowerCase()] ?? defaultLimit;
  }
}
