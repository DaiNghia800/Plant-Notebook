import 'package:flutter/material.dart';
import 'package:plant_notebook/data/models/library_plant_item.dart';

const List<String> _defaultFunFacts = [
  'Cây trong nhà thường xanh hơn khi được xoay chậu định kỳ mỗi 1-2 tuần.',
];

const List<LibraryPlantItem> libraryPlantSeed = [
  LibraryPlantItem(
    id: 'fiddle-leaf-fig',
    name: 'Fiddle Leaf Fig',
    category: 'Trong nhà',
    shortDescription:
        'Bản giao hưởng của những tán lá rộng, yêu cầu ánh sáng gián tiếp và độ ẩm ổn định.',
    description:
        'Fiddle Leaf Fig (Bàng Singapore) nổi bật với tán lá to và dáng cao, hợp làm điểm nhấn trong phòng khách hoặc văn phòng.',
    lightLevel: 'Sáng gián tiếp',
    waterNeed: 'Trung bình',
    difficulty: 'Trung bình',
    careGuide: [
      'Đặt gần cửa sổ có ánh sáng tán xạ, tránh nắng gắt trực tiếp.',
      'Tưới khi bề mặt đất khô 2-3 cm, không để úng rễ.',
    ],
    funFacts: _defaultFunFacts,
    imageUrl:
        'https://images.unsplash.com/photo-1593691512422-28cb17fb9b83?auto=format&fit=crop&w=1200&q=80',
    isTrending: true,
    scientificName: 'Ficus lyrata',
    humidityLevel: 'Trung bình đến Cao',
    toxicity: 'Độc với thú cưng',
    wateringIntervalDays: 7,
    wateringFrequencyLabel: '1 lần/tuần',
  ),
  LibraryPlantItem(
    id: 'snake-plant',
    name: 'Snake Plant',
    category: 'Trong nhà',
    shortDescription:
        'Sức sống mãnh liệt, lọc không khí tuyệt vời và không cần tưới nước thường xuyên.',
    description:
        'Snake Plant (Lưỡi Hổ) là lựa chọn phù hợp cho người mới bắt đầu nhờ khả năng chịu hạn tốt và dễ thích nghi môi trường.',
    lightLevel: 'Ít sáng',
    waterNeed: 'Thấp',
    difficulty: 'Dễ',
    careGuide: [
      'Tưới thưa, khoảng 7-14 ngày/lần tùy độ ẩm không khí.',
      'Dùng chậu thoát nước tốt để tránh thối gốc.',
    ],
    funFacts: _defaultFunFacts,
    imageUrl:
        'https://images.unsplash.com/photo-1598880940080-ff9a29891b85?auto=format&fit=crop&w=1200&q=80',
    badge: 'water',
    scientificName: 'Sansevieria trifasciata',
    humidityLevel: 'Thấp',
    toxicity: 'Độc với thú cưng',
    wateringIntervalDays: 14,
    wateringFrequencyLabel: '2 tuần/lần',
  ),
  LibraryPlantItem(
    id: 'monstera',
    name: 'Monstera',
    category: 'Trong nhà',
    shortDescription:
        'Cây trầu bà lá xẻ mang vẻ đẹp nhiệt đới ấn tượng cho mọi không gian sống.',
    description:
        'Monstera có lá xẻ đẹp mắt, phù hợp làm cây trang trí chủ đạo cho không gian sống theo phong cách hiện đại.',
    lightLevel: 'Sáng gián tiếp',
    waterNeed: 'Trung bình',
    difficulty: 'Dễ',
    careGuide: [
      'Giữ đất ẩm vừa, tưới khi mặt đất bắt đầu se khô.',
      'Ưa môi trường thoáng khí, độ ẩm trung bình đến cao.',
    ],
    funFacts: _defaultFunFacts,
    imageUrl:
        'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?auto=format&fit=crop&w=1200&q=80',
    badge: 'sun',
    scientificName: 'Monstera deliciosa',
    humidityLevel: 'Cao',
    toxicity: 'Độc với thú cưng',
    wateringIntervalDays: 7,
    wateringFrequencyLabel: '1 lần/tuần',
  ),
  LibraryPlantItem(
    id: 'string-of-pearls',
    name: 'String of Pearls',
    category: 'Sen đá',
    shortDescription:
        'Loại mọng nước chuỗi hạt này mọc rủ rất đẹp, thích hợp treo ban công.',
    description:
        'String of Pearls là dòng sen đá thân rủ, nổi bật với chuỗi lá tròn như hạt ngọc và khả năng chịu hạn tốt.',
    lightLevel: 'BRIGHT INDIRECT',
    waterNeed: 'Thấp',
    difficulty: 'Trung bình',
    temperatureRange: '18-24°C',
    careGuide: [
      'Cần nhiều ánh sáng để giữ dáng, tránh thiếu sáng kéo dài.',
      'Chỉ tưới khi đất khô hoàn toàn để tránh úng.',
    ],
    funFacts: _defaultFunFacts,
    imageUrl:
        'https://images.unsplash.com/photo-1526397751294-331021109fbd?auto=format&fit=crop&w=1200&q=80',
    isRare: true,
    scientificName: 'Senecio rowleyanus',
    humidityLevel: 'Thấp',
    toxicity: 'Độc với thú cưng',
    wateringIntervalDays: 14,
    wateringFrequencyLabel: '2 tuần/lần',
  ),
  LibraryPlantItem(
    id: 'aloe-vera',
    name: 'Aloe Vera',
    category: 'Sen đá',
    shortDescription:
        'Vừa là cây cảnh vừa là dược liệu quý với khả năng làm dịu da tức thì.',
    description:
        'Aloe Vera (Nha Đam) là loại mọng nước dễ sống, lá dày chứa gel thường dùng trong chăm sóc da tự nhiên.',
    lightLevel: 'Sáng trực tiếp nhẹ',
    waterNeed: 'Thấp',
    difficulty: 'Dễ',
    careGuide: [
      'Ưa ánh sáng mạnh, nên đặt gần ban công hoặc cửa sổ.',
      'Tưới ít, đảm bảo đất khô trước lần tưới tiếp theo.',
    ],
    funFacts: _defaultFunFacts,
    imageUrl:
        'https://images.unsplash.com/photo-1509423350716-97f2360af9f4?auto=format&fit=crop&w=1200&q=80',
    badge: 'camera',
    scientificName: 'Aloe barbadensis miller',
    humidityLevel: 'Thấp',
    toxicity: 'Độc với thú cưng',
    wateringIntervalDays: 14,
    wateringFrequencyLabel: '2 tuần/lần',
  ),
  LibraryPlantItem(
    id: 'pothos',
    name: 'Cây Trầu Bà',
    category: 'Trong nhà',
    shortDescription: 'Lá xanh mềm, dễ chăm, hợp kệ treo và bàn làm việc.',
    description:
        'Cây Trầu Bà là lựa chọn thân thiện cho người mới bắt đầu nhờ khả năng thích nghi tốt, tốc độ phát triển ổn định và dáng lá mềm mại rất hợp không gian sống hiện đại.',
    lightLevel: 'Indirect sun',
    waterNeed: 'Trung bình',
    difficulty: 'Dễ',
    temperatureRange: '18-30°C',
    careGuide: [
      'Trầu bà ưa bóng râm, tránh ánh nắng trực tiếp gay gắt để làm cháy lá. Tưới nước khi thấy lớp đất mặt se khô.',
      'Giữ nhiệt độ phòng ổn định từ 18-30°C. Thường xuyên lau bụi trên lá để cây quang hợp tốt hơn.',
    ],
    funFacts: _defaultFunFacts,
    imageUrl:
        'https://images.unsplash.com/photo-1604762524887-5a1a5f2c4f43?auto=format&fit=crop&w=1200&q=80',
    scientificName: 'Epipremnum aureum',
    humidityLevel: 'Trung bình',
    toxicity: 'Độc với thú cưng',
    wateringIntervalDays: 5,
    wateringFrequencyLabel: '2 lần/tuần',
  ),
];
