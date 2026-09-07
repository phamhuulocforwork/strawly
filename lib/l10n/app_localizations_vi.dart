// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Strawly - Theo dõi chu kỳ kinh nguyệt';

  @override
  String get appName => 'Strawly';

  @override
  String get homeSubtitle => 'Đồng hành cùng em 💕';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navStats => 'Thống kê';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get addCycleTooltip => 'Thêm chu kỳ';

  @override
  String get loadingPrediction => 'Đang tải dự đoán...';

  @override
  String get predictionError => 'Không tải được dự đoán';

  @override
  String get loadingCalendar => 'Đang mở lịch...';

  @override
  String get calendarError => 'Lịch chưa mở được';

  @override
  String get avgCycle => 'Chu kỳ TB';

  @override
  String get loadingAvgCycle => 'Đang tính chu kỳ trung bình...';

  @override
  String get regularity => 'Đều đặn';

  @override
  String get loadingRegularity => 'Đang xem độ đều đặn...';

  @override
  String get recentCycles => 'Chu kỳ gần đây';

  @override
  String get ongoing => 'Chu kỳ hiện tại';

  @override
  String lengthDays(int count) {
    return 'Dài $count ngày';
  }

  @override
  String avgCycleDays(String value) {
    return '$value ngày';
  }

  @override
  String get predictionUnavailable => 'Chưa dự đoán được';

  @override
  String get noPredictionYet => 'Chưa có dự đoán';

  @override
  String get addMoreCyclesForPrediction =>
      'Em thêm vài chu kỳ nữa nhé, app sẽ dự đoán giúp em.';

  @override
  String get nextPeriodPrediction => 'Dự đoán kỳ kinh tới';

  @override
  String get nextPeriod => 'Kỳ kinh tới';

  @override
  String daysLeft(int count) {
    return 'Còn $count ngày nữa';
  }

  @override
  String get expectedToday => 'Hôm nay có thể tới';

  @override
  String daysOverdue(int count) {
    return 'Trễ $count ngày rồi';
  }

  @override
  String get cycleCalendar => 'Lịch chu kỳ';

  @override
  String get legendPeriod => 'Ngày 🍓';

  @override
  String get legendFertile => 'Dễ có bé';

  @override
  String get legendPredicted => 'Dự đoán';

  @override
  String get periodDateRange => 'Ngày kỳ kinh';

  @override
  String get periodDates => 'Ngày hành kinh';

  @override
  String get periodDatesHint => 'Em chạm ngày bắt đầu, rồi ngày kết thúc nhé.';

  @override
  String daysSelected(int count) {
    return 'Đã chọn $count ngày';
  }

  @override
  String dateRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get periodSelectFirstDay => 'Em chọn ngày đầu tiên của kỳ kinh nhé.';

  @override
  String get periodSelectLastDay => 'Em chọn thêm ngày cuối của kỳ kinh nhé.';

  @override
  String get periodOutOfRange => 'Ngày em chọn nằm ngoài khoảng cho phép rồi.';

  @override
  String periodDurationRange(int min, int max) {
    return 'Kỳ kinh thường từ $min–$max ngày nhé.';
  }

  @override
  String get addCycle => 'Thêm chu kỳ';

  @override
  String get editCycle => 'Sửa chu kỳ';

  @override
  String get cycleEntryHelp => 'Ghi chú nhanh';

  @override
  String get cycleEntryHelpText =>
      'Em chọn kỳ kinh trên lịch bên dưới nhé. Khi em thêm chu kỳ mới, app sẽ tự tính độ dài chu kỳ.';

  @override
  String get cycleLength => 'Độ dài chu kỳ';

  @override
  String get totalCycleLengthOptional => 'Độ dài chu kỳ (không bắt buộc)';

  @override
  String get cycleLengthHint => 'vd: 28';

  @override
  String get daysSuffix => 'ngày';

  @override
  String get enterValidNumber => 'Em nhập số hợp lệ nhé';

  @override
  String cycleLengthRange(int short, int long) {
    return '$short - $long ngày';
  }

  @override
  String get notesOptional => 'Ghi chú (tuỳ chọn)';

  @override
  String get notesHint =>
      'Em có thể ghi triệu chứng, tâm trạng, hay điều gì em muốn nhớ...🥺';

  @override
  String get updateCycle => 'Cập nhật';

  @override
  String get cycleUpdatedSuccess => 'Đã cập nhật chu kỳ cho em rồi nhé 👌';

  @override
  String get cycleAddedSuccess => 'Đã lưu chu kỳ mới cho em rồi 👌';

  @override
  String errorMessage(String message) {
    return 'Có lỗi: $message';
  }

  @override
  String get settings => 'Cài đặt';

  @override
  String get appearance => 'Giao diện';

  @override
  String get darkMode => 'Chế độ tối';

  @override
  String get darkModeSubtitle => 'Bật giao diện tối cho dễ nhìn hơn';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageSubtitle => 'Ngôn ngữ và cách hiển thị ngày';

  @override
  String get languageSystem => 'Theo máy';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get dataManagement => 'Dữ liệu';

  @override
  String get exportData => 'Xuất dữ liệu';

  @override
  String get exportDataSubtitle => 'Sao lưu dữ liệu';

  @override
  String get importData => 'Nhập dữ liệu';

  @override
  String get importDataSubtitle => 'Khôi phục từ bản sao lưu';

  @override
  String get deleteAllData => 'Xóa hết dữ liệu';

  @override
  String get deleteAllDataSubtitle => 'Xóa vĩnh viễn dữ liệu';

  @override
  String get about => 'Giới thiệu';

  @override
  String get aboutStrawly => 'Về Strawly';

  @override
  String get version => 'Phiên bản';

  @override
  String get versionNumber => '1.0.0';

  @override
  String get privacy => 'Riêng tư';

  @override
  String get privacySubtitle =>
      'Mọi thứ chỉ lưu trên máy em, không ai khác thấy đâu';

  @override
  String get security => 'Bảo mật';

  @override
  String get securitySubtitle => 'Dữ liệu được mã hóa AES-256';

  @override
  String get brandingSubtitle => 'Theo dõi chu kỳ riêng tư — dành riêng cho em';

  @override
  String get strawlyBranding => 'Strawly';

  @override
  String get dataExported => 'Đã sao lưu vào clipboard rồi nhé';

  @override
  String exportFailed(String error) {
    return 'Xuất không được: $error';
  }

  @override
  String get importDataTitle => 'Nhập dữ liệu';

  @override
  String get importDataConfirm =>
      'Việc này sẽ thay toàn bộ dữ liệu hiện tại của em. Em nhớ sao lưu trước nhé.\n\nỞ bước sau, em dán JSON sao lưu vào.';

  @override
  String get cancel => 'Huỷ';

  @override
  String get continueButton => 'Tiếp tục';

  @override
  String get pasteBackupTitle => 'Dán bản sao lưu';

  @override
  String get pasteBackupHint => 'Em dán JSON sao lưu vào đây nhé';

  @override
  String get importButton => 'Nhập';

  @override
  String importedCycles(int count) {
    return 'Đã nhập $count chu kỳ cho em rồi';
  }

  @override
  String importFailed(String error) {
    return 'Nhập không được: $error';
  }

  @override
  String get deleteAllDataTitle => 'Xóa hết dữ liệu?';

  @override
  String get deleteAllDataConfirm =>
      'Mọi dữ liệu chu kỳ của em sẽ bị xóa vĩnh viễn, không khôi phục được.\n\nNếu em muốn giữ lại, hãy xuất dữ liệu trước nhé.';

  @override
  String get deleteAllButton => 'Xóa hết';

  @override
  String get allDataDeleted => 'Đã xóa hết dữ liệu rồi';

  @override
  String deleteFailed(String error) {
    return 'Xóa không được: $error';
  }

  @override
  String get deleteCycleTitle => 'Xóa chu kỳ này?';

  @override
  String deleteCycleConfirm(String date) {
    return 'Chu kỳ bắt đầu $date sẽ bị xóa, không khôi phục được.';
  }

  @override
  String get deleteCycleButton => 'Xóa';

  @override
  String get cycleDeleted => 'Đã xóa chu kỳ';

  @override
  String get statistics => 'Thống kê';

  @override
  String get statisticsError => 'Thống kê chưa tải được';

  @override
  String get noStatisticsYet => 'Chưa có thống kê';

  @override
  String get noDataYet => 'Chưa có dữ liệu';

  @override
  String get addCyclesForInsights =>
      'Em thêm chu kỳ để xem thêm thông tin nhé.';

  @override
  String get totalCycles => 'Tổng chu kỳ';

  @override
  String get complete => 'Đủ dữ liệu';

  @override
  String get stdDev => 'Đ.l chuẩn';

  @override
  String get cycleLengthHistory => 'Lịch sử độ dài chu kỳ';

  @override
  String get notEnoughChartData => 'Chưa đủ dữ liệu để vẽ biểu đồ.';

  @override
  String lastNCycles(int count) {
    return '$count chu kỳ gần nhất của em';
  }

  @override
  String get regularityScore => 'Mức đều đặn';

  @override
  String get deviationFromAverage => 'Lệch so với trung bình';

  @override
  String get averageShort => 'TB';

  @override
  String get avgPeriod => 'TB ngày hành kinh';

  @override
  String get shortestCycle => 'Chu kỳ ngắn nhất';

  @override
  String get longestCycle => 'Chu kỳ dài nhất';

  @override
  String get currentCycleDay => 'Ngày chu kỳ hiện tại';

  @override
  String currentCycleDayValue(int day) {
    return 'Ngày $day';
  }

  @override
  String get shortestLongest => 'Ngắn nhất / Dài nhất';

  @override
  String predictionReadyStatus(int count) {
    return 'Đủ dữ liệu để dự đoán: $count chu kỳ';
  }

  @override
  String get cyclesRegular => 'Chu kỳ của em đều quá nè :3';

  @override
  String get cyclesVariation => 'Chu kỳ của em hơi biến động một chút 🥺';

  @override
  String get additionalInformation => 'Thông tin khác';

  @override
  String get completeCycles => 'Chu kỳ đủ dữ liệu';

  @override
  String get standardDeviation => 'Độ lệch chuẩn';

  @override
  String get nextExpected => 'Dự kiến lần tới';

  @override
  String daysUnit(String count) {
    return '$count ngày';
  }

  @override
  String get somethingWentWrong => 'Có gì đó không ổn';

  @override
  String get predictedNextPeriod => 'Dự kiến kỳ tiếp theo';

  @override
  String get daysLabel => 'ngày';

  @override
  String get logPeriodToday => 'Ghi nhận 🍓 hôm nay';

  @override
  String get loggedPeriodToday => 'Đã ghi nhận hôm nay';

  @override
  String get phasePeriod => 'Kỳ kinh';

  @override
  String get phaseFollicular => 'Pha nang';

  @override
  String get phaseFertile => 'Dễ có bé';

  @override
  String get phaseLuteal => 'Hoàng thể';

  @override
  String get periodLoggedSuccess => 'Đã ghi nhận kỳ kinh — dự đoán đã cập nhật';
}
