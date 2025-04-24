const String kApiBaseUrl = 'http://localhost:3000/api';
const String kAuthTokenKey = 'authToken';

const double kDefaultPadding = 16.0;
const Duration kApiTimeoutDuration = Duration(seconds: 30);

const List<String> kDefaultExpenseCategories = [
  'Food',
  'Transport',
  'Entertainment',
  'Utilities',
  'Shopping',
  'Health',
  'Education',
  'Salary',
  'Freelance',
  'Other',
];

const String kDisplayDateFormat = 'dd MMM yyyy';
const String kApiDateFormat = 'yyyy-MM-dd';

const String kThemeModeKey = 'themeMode';

const String splashRoute = '/splash';
const String loginRoute = '/auth/login';
const String registerRoute = '/auth/register';
const String homeRoute = '/home';
const String addEditExpenseRoute = '/add-edit-expense';
const String expenseDetailRoute = '/expense-detail';
const String monthlyAnalyticsRoute = '/monthly-analytics';
