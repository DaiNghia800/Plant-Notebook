import 'package:plant_notebook/features/library-plant/models/library_plant_item.dart';

const List<LibraryPlantItem> libraryPlantSeed = [
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
    imageUrl:
        'https://images.unsplash.com/photo-1485955900006-10f4d324d411?auto=format&fit=crop&w=1200&q=80',
  ),
];
