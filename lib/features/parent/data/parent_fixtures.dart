/// JSON fixtures for parent endpoints. No Flutter imports, so the mock
/// HTTP server and Dio interceptor can share them.
class ParentFixtures {
  ParentFixtures._();

  static Map<String, dynamic> dashboardJson() => {
    'family_balance': 182.70,
    'added_this_week': 50.00,
    'show_alert': true,
    'alert_message': "Kwame's Game Shop purchase needs review",
    'children': [
      {
        'id': 'child_amara',
        'name': 'Amara',
        'age': 14,
        'avatar': '🧕',
        'balance': 124.50,
        'limit': 200.0,
        'spent': 75.50,
        'color': 'primary',
      },
      {
        'id': 'child_kwame',
        'name': 'Kwame',
        'age': 11,
        'avatar': '👦🏾',
        'balance': 58.20,
        'limit': 100.0,
        'spent': 41.80,
        'color': 'accent',
      },
    ],
    'spend_categories': [
      {'label': 'Food', 'pct': 42, 'color': 'primary'},
      {'label': 'Education', 'pct': 28, 'color': 'accent'},
      {'label': 'Transport', 'pct': 18, 'color': 'warning'},
      {'label': 'Entertainment', 'pct': 12, 'color': 'gold'},
    ],
    'recent_transactions': [
      {
        'child_name': 'Amara',
        'merchant': 'School Canteen',
        'amount': -4.50,
        'time': 'Today, 12:30',
        'cat': '🍔',
        'approved': true,
      },
      {
        'child_name': 'Kwame',
        'merchant': 'Stationery World',
        'amount': -12.00,
        'time': 'Today, 10:15',
        'cat': '📚',
        'approved': true,
      },
      {
        'child_name': 'Amara',
        'merchant': 'Allowance',
        'amount': 50.00,
        'time': 'Yesterday',
        'cat': '💸',
        'approved': true,
      },
      {
        'child_name': 'Kwame',
        'merchant': 'Game Shop',
        'amount': -18.00,
        'time': 'Yesterday',
        'cat': '🎮',
        'approved': false,
      },
      {
        'child_name': 'Amara',
        'merchant': 'Bus Pass',
        'amount': -15.00,
        'time': 'Mon',
        'cat': '🚌',
        'approved': true,
      },
    ],
  };

  static Map<String, dynamic> ledgerJson() => {
    'transactions': [
      _txn('Amara', 'School Canteen', -4.50, 'Today', '12:30', '🍔', 'approved'),
      _txn('Kwame', 'Stationery World', -12.00, 'Today', '10:15', '📚', 'approved'),
      _txn('Amara', 'Weekly Allowance', 50.00, 'Today', '9:00', '💸', 'approved'),
      _txn('Kwame', 'Weekly Allowance', 30.00, 'Today', '9:00', '💸', 'approved'),
      _txn('Kwame', 'Game Shop', -18.00, 'Yesterday', '16:20', '🎮', 'flagged'),
      _txn('Amara', 'Bus Pass', -15.00, 'Mon', '7:45', '🚌', 'approved'),
      _txn('Amara', 'Health Clinic', -8.00, 'Mon', '14:00', '🏥', 'approved'),
      _txn('Kwame', 'Lunch Break', -5.50, 'Mon', '12:30', '🍔', 'approved'),
      _txn('Amara', 'Art Supplies', -22.00, 'Sun', '11:00', '🎨', 'approved'),
      _txn('Kwame', 'Books R Us', -9.00, 'Sun', '13:45', '📚', 'approved'),
    ],
  };

  static Map<String, dynamic> _txn(
    String child,
    String merchant,
    double amount,
    String date,
    String time,
    String cat,
    String status,
  ) => {
    'child': child,
    'merchant': merchant,
    'amount': amount,
    'date': date,
    'time': time,
    'cat': cat,
    'status': status,
  };

}
