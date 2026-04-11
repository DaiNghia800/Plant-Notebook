import 'package:flutter/material.dart';
import 'package:plant_notebook/features/library-plant/models/library_plant_item.dart';

const List<PlantCareLogEntry> _defaultCareLogs = [
  PlantCareLogEntry(
    title: 'Đã tưới nước',
    timeLabel: '2 ngày trước • 08:30 AM',
    note: 'Tưới vừa đủ khi mặt đất bắt đầu se khô.',
    icon: Icons.water_drop_rounded,
    accentColor: Color(0xFF1B7A3D),
  ),
  PlantCareLogEntry(
    title: 'Bón phân hữu cơ',
    timeLabel: '1 tuần trước • 09:15 AM',
    note: 'Bổ sung một lượng nhỏ để cây tiếp tục ra lá mới.',
    icon: Icons.eco_rounded,
    accentColor: Color(0xFF6C8F49),
  ),
  PlantCareLogEntry(
    title: 'Đã tưới nước',
    timeLabel: '9 ngày trước • 07:45 AM',
    note: 'Kiểm tra độ ẩm trước khi tưới để tránh úng rễ.',
    icon: Icons.water_drop_rounded,
    accentColor: Color(0xFF1B7A3D),
  ),
];

const List<PlantGrowthSnapshot> _defaultGrowthTimeline = [
  PlantGrowthSnapshot(
    monthLabel: 'Tháng 2',
    imageUrl:
        'https://images.unsplash.com/photo-1592150621744-aca64f48394e?auto=format&fit=crop&w=1200&q=80',
    note: 'Cây bắt đầu ổn định sau khi thay chậu.',
  ),
  PlantGrowthSnapshot(
    monthLabel: 'Tháng 3',
    imageUrl:
        'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?auto=format&fit=crop&w=1200&q=80',
    note: 'Lá mới mọc nhanh hơn và tán lá dày hơn.',
  ),
  PlantGrowthSnapshot(
    monthLabel: 'Tháng 4',
    imageUrl:
        'https://images.unsplash.com/photo-1593691512422-28cb17fb9b83?auto=format&fit=crop&w=1200&q=80',
    note: 'Tán lá phát triển cân đối, phù hợp trưng bày trong nhà.',
  ),
];

const List<String> _defaultFunFacts = [
  'Cây trong nhà thường xanh hơn khi được xoay chậu định kỳ mỗi 1-2 tuần.',
  'Lau bụi trên lá giúp cây quang hợp tốt hơn và giảm nguy cơ sâu bệnh.',
  'Ánh sáng gián tiếp mạnh là lựa chọn an toàn cho đa số cây trồng trong nhà.',
];

const List<LibraryPlantItem> libraryPlantSeed = [
  LibraryPlantItem(
    id: 'pothos',
    name: 'Cây Trầu Bà',
    category: 'Trong nhà',
    shortDescription: 'Lá xanh mềm, dễ chăm, hợp kệ treo và bàn làm việc.',
    description:
        'Cây Trầu Bà là lựa chọn thân thiện cho người mới bắt đầu nhờ khả năng thích nghi tốt, tốc độ phát triển ổn định và dáng lá mềm mại rất hợp không gian sống hiện đại.',
    lightLevel: 'Sáng gián tiếp',
    waterNeed: 'Trung bình',
    difficulty: 'Dễ',
    careGuide: [
      'Đặt cây ở nơi có ánh sáng tán xạ, tránh nắng gắt chiếu trực tiếp vào lá.',
      'Tưới khi lớp đất mặt se khô, giữ ẩm vừa phải để rễ phát triển khỏe.',
      'Cắt tỉa lá vàng và xoay chậu định kỳ để tán lá cân đối hơn.',
    ],
    careLogs: _defaultCareLogs,
    growthTimeline: _defaultGrowthTimeline,
    funFacts: [
      'Trầu Bà có thể leo hoặc rủ tự nhiên, rất hợp làm điểm nhấn gần cửa sổ.',
      'Nếu lá nhạt màu, cây thường đang cần thêm ánh sáng gián tiếp.',
      'Trầu Bà là một trong những cây nội thất được ưa chuộng nhất nhờ khả năng sống khỏe.',
    ],
    imageUrl:
        'https://images.unsplash.com/photo-1604762524887-5a1a5f2c4f43?auto=format&fit=crop&w=1200&q=80',
    isTrending: true,
    healthStatus: 'Khỏe mạnh',
    wateringFrequencyLabel: '2 lần/tuần',
    lastWateredLabel: '2 ngày trước',
  ),
  LibraryPlantItem(
    id: 'fiddle-leaf-fig',
    name: 'Fiddle Leaf Fig',
    category: 'Trong nhà',
    shortDescription: 'Lá lớn nổi bật, hợp không gian hiện đại.',
    description:
        'Fiddle Leaf Fig (Bàng Singapore) nổi bật với tán lá to và dáng cao, hợp làm điểm nhấn trong phòng khách hoặc văn phòng.',
    lightLevel: 'Sáng gián tiếp',
    waterNeed: 'Trung bình',
    difficulty: 'Trung bình',
    careGuide: [
      'Đặt gần cửa sổ có ánh sáng tán xạ, tránh nắng gắt trực tiếp.',
      'Tưới khi bề mặt đất khô 2-3 cm, không để úng rễ.',
      'Lau bụi mặt lá 1 lần/tuần để cây quang hợp tốt hơn.',
    ],
    careLogs: _defaultCareLogs,
    growthTimeline: _defaultGrowthTimeline,
    funFacts: _defaultFunFacts,
    imageUrl:
        'https://images.unsplash.com/photo-1593691512422-28cb17fb9b83?auto=format&fit=crop&w=1200&q=80',
    isTrending: true,
  ),
  LibraryPlantItem(
    id: 'snake-plant',
    name: 'Snake Plant',
    category: 'Trong nhà',
    shortDescription: 'Sống khỏe, lọc không khí, ít cần chăm sóc.',
    description:
        'Snake Plant (Lưỡi Hổ) là lựa chọn phù hợp cho người mới bắt đầu nhờ khả năng chịu hạn tốt và dễ thích nghi môi trường.',
    lightLevel: 'Ít sáng',
    waterNeed: 'Thấp',
    difficulty: 'Dễ',
    careGuide: [
      'Tưới thưa, khoảng 7-14 ngày/lần tùy độ ẩm không khí.',
      'Dùng chậu thoát nước tốt để tránh thối gốc.',
      'Có thể đặt ở góc phòng vẫn phát triển ổn định.',
    ],
    careLogs: _defaultCareLogs,
    growthTimeline: _defaultGrowthTimeline,
    funFacts: _defaultFunFacts,
    imageUrl:
        'https://images.unsplash.com/photo-1598880940080-ff9a29891b85?auto=format&fit=crop&w=1200&q=80',
  ),
  LibraryPlantItem(
    id: 'monstera',
    name: 'Monstera',
    category: 'Trong nhà',
    shortDescription: 'Lá xẻ đặc trưng, tạo cảm giác nhiệt đới.',
    description:
        'Monstera có lá xẻ đẹp mắt, phù hợp làm cây trang trí chủ đạo cho không gian sống theo phong cách hiện đại.',
    lightLevel: 'Sáng gián tiếp',
    waterNeed: 'Trung bình',
    difficulty: 'Dễ',
    careGuide: [
      'Giữ đất ẩm vừa, tưới khi mặt đất bắt đầu se khô.',
      'Ưa môi trường thoáng khí, độ ẩm trung bình đến cao.',
      'Xoay chậu định kỳ để tán lá phát triển cân đối.',
    ],
    careLogs: _defaultCareLogs,
    growthTimeline: _defaultGrowthTimeline,
    funFacts: _defaultFunFacts,
    imageUrl:
        'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?auto=format&fit=crop&w=1200&q=80',
  ),
  LibraryPlantItem(
    id: 'string-of-pearls',
    name: 'String of Pearls',
    category: 'Sen đá',
    shortDescription: 'Dáng rủ độc đáo, hợp kệ cao hoặc chậu treo.',
    description:
        'String of Pearls là dòng sen đá thân rủ, nổi bật với chuỗi lá tròn như hạt ngọc và khả năng chịu hạn tốt.',
    lightLevel: 'Sáng trực tiếp nhẹ',
    waterNeed: 'Thấp',
    difficulty: 'Trung bình',
    careGuide: [
      'Cần nhiều ánh sáng để giữ dáng, tránh thiếu sáng kéo dài.',
      'Chỉ tưới khi đất khô hoàn toàn để tránh úng.',
      'Ưu tiên đất thoát nước nhanh chuyên cho sen đá.',
    ],
    careLogs: _defaultCareLogs,
    growthTimeline: _defaultGrowthTimeline,
    funFacts: _defaultFunFacts,
    imageUrl:
        'https://images.unsplash.com/photo-1526397751294-331021109fbd?auto=format&fit=crop&w=1200&q=80',
    isRare: true,
  ),
  LibraryPlantItem(
    id: 'aloe-vera',
    name: 'Aloe Vera',
    category: 'Sen đá',
    shortDescription: 'Vừa trang trí vừa hữu ích cho chăm sóc da.',
    description:
        'Aloe Vera (Nha Đam) là loại mọng nước dễ sống, lá dày chứa gel thường dùng trong chăm sóc da tự nhiên.',
    lightLevel: 'Sáng trực tiếp nhẹ',
    waterNeed: 'Thấp',
    difficulty: 'Dễ',
    careGuide: [
      'Ưa ánh sáng mạnh, nên đặt gần ban công hoặc cửa sổ.',
      'Tưới ít, đảm bảo đất khô trước lần tưới tiếp theo.',
      'Không để nước đọng ở bẹ lá để tránh nấm bệnh.',
    ],
    careLogs: _defaultCareLogs,
    growthTimeline: _defaultGrowthTimeline,
    funFacts: _defaultFunFacts,
    imageUrl:
        'https://images.unsplash.com/photo-1509423350716-97f2360af9f4?auto=format&fit=crop&w=1200&q=80',
  ),
  LibraryPlantItem(
    id: 'money-tree',
    name: 'Money Tree',
    category: 'Phong thủy',
    shortDescription: 'Biểu tượng tài lộc, thường đặt ở bàn làm việc.',
    description:
        'Money Tree (Kim Ngân) được ưa chuộng trong trang trí nội thất vì ý nghĩa phong thủy và khả năng thích nghi tốt.',
    lightLevel: 'Sáng gián tiếp',
    waterNeed: 'Trung bình',
    difficulty: 'Dễ',
    careGuide: [
      'Đặt nơi có ánh sáng nhẹ, tránh nắng trưa trực tiếp.',
      'Tưới đều khi đất vừa se khô, không tưới quá tay.',
      'Cắt tỉa lá vàng định kỳ để cây luôn xanh khỏe.',
    ],
    careLogs: _defaultCareLogs,
    growthTimeline: _defaultGrowthTimeline,
    funFacts: _defaultFunFacts,
    imageUrl:
        'https://images.unsplash.com/photo-1485955900006-10f4d324d411?auto=format&fit=crop&w=1200&q=80',
  ),
];
