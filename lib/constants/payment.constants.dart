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
