class CarouselItem {
  final String title;
  final String subtitle;
  final String tag;
  final String imageAsset;
  final String? chipLabel;
  final String? description;

  const CarouselItem({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.imageAsset,
    this.chipLabel,
    this.description,
  });
}

class HomeCountryData {
  static List<CarouselItem> getPlaces(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'TH':
        return const [
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Thailand',
            subtitle: 'New places. New stories.\nSame you.',
            imageAsset: 'assets/images/countries/thailand/place/bangkok.png',
            chipLabel: 'Bangkok',
            description: 'Capital of Thailand, known for ornate shrines, bustling street life, and the Chao Phraya River.',
          ),
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Chiang Mai',
            subtitle: 'Misty mountains &\nancient temples.',
            imageAsset: 'assets/images/countries/thailand/place/chiang.png',
            chipLabel: 'Chiang Mai',
            description: 'Northern cultural hub renowned for its historic temples, lush mountain passes, and artisan night bazaars.',
          ),
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Phuket',
            subtitle: 'Crystal turquoise waters &\nisland escapes.',
            imageAsset: 'assets/images/countries/thailand/place/phuket.png',
            chipLabel: 'Phuket',
            description: 'Thailand\'s largest island, lined with tropical rainforests, pristine beaches, and vibrant markets.',
          ),
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Krabi',
            subtitle: 'Limestone sea cliffs &\nhidden lagoons.',
            imageAsset: 'assets/images/countries/thailand/place/krabi.png',
            chipLabel: 'Krabi',
            description: 'Stunning southern province with dramatic sheer limestone karsts and emerald coastal lagoons.',
          ),
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Pattaya',
            subtitle: 'Vibrant coastlines &\nlively nights.',
            imageAsset: 'assets/images/countries/thailand/place/pattaya.png',
            chipLabel: 'Pattaya',
            description: 'Famous seaside resort town on the eastern Gulf coast of Thailand known for beaches and watersports.',
          ),
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Hua Hin',
            subtitle: 'Royal seaside &\ntranquil beaches.',
            imageAsset: 'assets/images/countries/thailand/place/huahin.png',
            chipLabel: 'Hua Hin',
            description: 'Historic royal seaside resort town offering peaceful sandy stretches and night food markets.',
          ),
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Hat Yai',
            subtitle: 'Southern gateway &\nbustling markets.',
            imageAsset: 'assets/images/countries/thailand/place/hatyai.png',
            chipLabel: 'Hat Yai',
            description: 'Commercial trading center in southern Thailand famous for floating markets and cross-border cuisine.',
          ),
        ];

      case 'VN':
        return const [
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Vietnam',
            subtitle: 'Emerald waters &\ntimeless heritage.',
            imageAsset: 'assets/images/countries/vietnam/place/halong.png',
            chipLabel: 'Ha Long Bay',
            description: 'Famous bay featuring thousands of towering limestone islands topped by rainforests.',
          ),
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Hanoi',
            subtitle: 'Old quarters &\nfragrant street stalls.',
            imageAsset: 'assets/images/countries/vietnam/place/hanoi.png',
            chipLabel: 'Hanoi',
            description: 'Centuries-old capital known for ancient architecture and rich culinary traditions.',
          ),
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Hoi An',
            subtitle: 'Lantern-lit canals &\nancient merchant homes.',
            imageAsset: 'assets/images/countries/vietnam/place/hoi.png',
            chipLabel: 'Hoi An',
            description: 'Well-preserved ancient port town laced with canals and glowing evening lanterns.',
          ),
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Phong Nha',
            subtitle: 'Majestic caves &\npristine jungle rivers.',
            imageAsset: 'assets/images/countries/vietnam/place/phongnina.png',
            chipLabel: 'Phong Nha',
            description: 'Home to the world\'s most immense and breathtaking karst cave systems.',
          ),
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Trang An',
            subtitle: 'Dramatic peaks &\nserene waterways.',
            imageAsset: 'assets/images/countries/vietnam/place/trang.png',
            chipLabel: 'Ninh Binh',
            description: 'UNESCO World Heritage landscape of limestone karst peaks and riverboat caves.',
          ),
        ];

      case 'ID':
        return const [
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Indonesia',
            subtitle: 'Emerald archipelago &\ntimeless culture.',
            imageAsset: 'assets/images/countries/indonesia/place/ubud.png',
            chipLabel: 'Ubud, Bali',
            description: 'The cultural heart of Bali, surrounded by lush rain forests, terraced rice paddies, and sacred Hindu shrines.',
          ),
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Borobudur',
            subtitle: 'World\'s largest ancient\nBuddhist monument.',
            imageAsset: 'assets/images/countries/indonesia/place/borobudur.png',
            chipLabel: 'Magelang',
            description: '9th-century Mahayana Buddhist temple rising gracefully over Central Java with 72 stupas and ancient stone carvings.',
          ),
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Uluwatu',
            subtitle: 'Clifftop temples &\nsunset Kecak fire dance.',
            imageAsset: 'assets/images/countries/indonesia/place/Uluwatu.png',
            chipLabel: 'Uluwatu',
            description: 'Perched on a steep cliff 70 meters above the roaring Indian Ocean with legendary sunset views.',
          ),
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Nusa Penida',
            subtitle: 'Dramatic sea cliffs &\nturquoise coastal bays.',
            imageAsset: 'assets/images/countries/indonesia/place/nusapenida.png',
            chipLabel: 'Kelingking',
            description: 'Iconic T-Rex shaped coastal cliff towering over pristine white sands and untouched turquoise waters.',
          ),
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Prambanan',
            subtitle: 'Soaring Hindu spires &\nJavanese legend.',
            imageAsset: 'assets/images/countries/indonesia/place/prambanan.png',
            chipLabel: 'Yogyakarta',
            description: 'Majestic 9th-century Hindu temple compound dedicated to the Trimurti, famed for towering pointed architecture.',
          ),
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Kelimutu',
            subtitle: 'Tri-colored volcanic\nlakes of wonder.',
            imageAsset: 'assets/images/countries/indonesia/place/kelimutu.png',
            chipLabel: 'Flores',
            description: 'Mystical volcano with three crater lakes that naturally change color between turquoise, green, and deep red.',
          ),
        ];

      case 'PH':
      default:
        return const [
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Indonesia',
            subtitle: 'Emerald archipelago &\ntimeless culture.',
            imageAsset: 'assets/images/countries/indonesia/place/ubud.png',
            chipLabel: 'Ubud, Bali',
            description: 'The cultural heart of Bali, surrounded by lush rain forests, terraced rice paddies, and sacred Hindu shrines.',
          ),
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Borobudur',
            subtitle: 'World\'s largest ancient\nBuddhist monument.',
            imageAsset: 'assets/images/countries/indonesia/place/borobudur.png',
            chipLabel: 'Magelang',
            description: '9th-century Mahayana Buddhist temple rising gracefully over Central Java with 72 stupas and ancient stone carvings.',
          ),
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Uluwatu',
            subtitle: 'Clifftop temples &\nsunset Kecak fire dance.',
            imageAsset: 'assets/images/countries/indonesia/place/Uluwatu.png',
            chipLabel: 'Uluwatu',
            description: 'Perched on a steep cliff 70 meters above the roaring Indian Ocean with legendary sunset views.',
          ),
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Nusa Penida',
            subtitle: 'Dramatic sea cliffs &\nturquoise coastal bays.',
            imageAsset: 'assets/images/countries/indonesia/place/nusapenida.png',
            chipLabel: 'Kelingking',
            description: 'Iconic T-Rex shaped coastal cliff towering over pristine white sands and untouched turquoise waters.',
          ),
          CarouselItem(
            tag: 'EXPLORE',
            title: 'Prambanan',
            subtitle: 'Soaring Hindu spires &\nJavanese legend.',
            imageAsset: 'assets/images/countries/indonesia/place/prambanan.png',
            chipLabel: 'Yogyakarta',
            description: 'Majestic 9th-century Hindu temple compound dedicated to the Trimurti, famed for towering pointed architecture.',
          ),
        ];
    }
  }

  static List<CarouselItem> getDishes(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'TH':
        return const [
          CarouselItem(
            tag: 'DISHES',
            title: 'Pad Thai=',
            subtitle: 'Taste your way through\nThailand.',
            imageAsset: 'assets/images/countries/thailand/dish/padthai.png',
            chipLabel: 'Pad Thai',
            description: 'Classic stir-fried rice noodles with prawns, tofu, crushed peanuts, and lime.',
          ),
          CarouselItem(
            tag: 'DISHES',
            title: 'Tom Kha Gai',
            subtitle: 'Aromatic coconut soup\nwith galangal & lime.',
            imageAsset: 'assets/images/countries/thailand/dish/tomkha.png',
            chipLabel: 'Tom Kha Gai',
            description: 'Rich, soothing coconut broth infused with lemongrass, kaffir lime, and chicken.',
          ),
          CarouselItem(
            tag: 'DISHES',
            title: 'Pad Kra Pao',
            subtitle: 'Spicy holy basil\nwok stir-fry heat.',
            imageAsset: 'assets/images/countries/thailand/dish/padkrapao.png',
            chipLabel: 'Pad Krapao',
            description: 'Beloved fiery street meal of minced meat stir-fried with Thai holy basil.',
          ),
          CarouselItem(
            tag: 'DISHES',
            title: 'Khao Soi',
            subtitle: 'Golden curry noodles\nof Northern Thailand.',
            imageAsset: 'assets/images/countries/thailand/dish/khaosoi.png',
            chipLabel: 'Khao Soi',
            description: 'Creamy coconut curry noodle soup topped with crispy deep-fried egg noodles.',
          ),
        ];

      case 'VN':
        return const [
          CarouselItem(
            tag: 'DISHES',
            title: 'Pho Hanoi',
            subtitle: 'Fragrant broths &\nfresh garden herbs.',
            imageAsset: 'assets/images/countries/vietnam/dish/phohanoi.png',
            chipLabel: 'Pho Hanoi',
            description: 'Vietnam\'s national dish: delicate rice noodles in slow-simmered aromatic bone broth.',
          ),
          CarouselItem(
            tag: 'DISHES',
            title: 'Bun Cha',
            subtitle: 'Charcoal-grilled pork &\nrice noodles.',
            imageAsset: 'assets/images/countries/vietnam/dish/buncha.png',
            chipLabel: 'Bun Cha',
            description: 'Grilled savory pork patties served over cold vermicelli with fresh dipping sauce.',
          ),
          CarouselItem(
            tag: 'DISHES',
            title: 'Goi Cuon',
            subtitle: 'Fresh spring rolls\nwith peanut sauce.',
            imageAsset: 'assets/images/countries/vietnam/dish/goi.png',
            chipLabel: 'Goi Cuon',
            description: 'Translucent rice paper rolls filled with shrimp, pork, herbs, and vermicelli.',
          ),
          CarouselItem(
            tag: 'DISHES',
            title: 'Bún bò Huế',
            subtitle: 'Spicy lemongrass\nbeef noodle soup.',
            imageAsset: 'assets/images/countries/vietnam/dish/huebeef.png',
            chipLabel: 'Bún bò Huế',
            description: 'Robust, spicy soup featuring thick noodles, beef shank, and lemongrass oil.',
          ),
        ];

      case 'ID':
        return const [
          CarouselItem(
            tag: 'DISHES',
            title: 'Nasi Goreng',
            subtitle: 'Wok-tossed aromatic\nIndonesian fried rice.',
            imageAsset: 'assets/images/countries/indonesia/dish/goreng.png',
            chipLabel: 'Nasi Goreng',
            description: 'National dish of Indonesia: savory stir-fried rice seasoned with sweet kecap manis, shallots, garlic, and fried egg.',
          ),
          CarouselItem(
            tag: 'DISHES',
            title: 'Sate Ayam',
            subtitle: 'Charcoal-grilled skewers\nin rich peanut sauce.',
            imageAsset: 'assets/images/countries/indonesia/dish/satay.png',
            chipLabel: 'Chicken Satay',
            description: 'Tender marinated chicken skewers grilled over coconut charcoal and smothered in velvety spicy peanut sauce.',
          ),
          CarouselItem(
            tag: 'DISHES',
            title: 'Soto Ayam',
            subtitle: 'Comforting turmeric\nchicken noodle broth.',
            imageAsset: 'assets/images/countries/indonesia/dish/soto.png',
            chipLabel: 'Soto Ayam',
            description: 'Fragrant golden soup infused with fresh turmeric, lemongrass, shredded chicken, vermicelli, and boiled egg.',
          ),
          CarouselItem(
            tag: 'DISHES',
            title: 'Gado-Gado',
            subtitle: 'Warm salad medley with\ncreamy peanut dressing.',
            imageAsset: 'assets/images/countries/indonesia/dish/gado-gado.png',
            chipLabel: 'Gado-Gado',
            description: 'Steamed vegetables, tofu, tempeh, and boiled eggs dressed in a rich sweet-and-savory spiced peanut sauce.',
          ),
        ];

      case 'PH':
      default:
        return const [
          CarouselItem(
            tag: 'DISHES',
            title: 'Nasi Goreng',
            subtitle: 'Wok-tossed aromatic\nIndonesian fried rice.',
            imageAsset: 'assets/images/countries/indonesia/dish/goreng.png',
            chipLabel: 'Nasi Goreng',
            description: 'National dish of Indonesia: savory stir-fried rice seasoned with sweet kecap manis, shallots, garlic, and fried egg.',
          ),
          CarouselItem(
            tag: 'DISHES',
            title: 'Sate Ayam',
            subtitle: 'Charcoal-grilled skewers\nin rich peanut sauce.',
            imageAsset: 'assets/images/countries/indonesia/dish/satay.png',
            chipLabel: 'Chicken Satay',
            description: 'Tender marinated chicken skewers grilled over coconut charcoal and smothered in velvety spicy peanut sauce.',
          ),
          CarouselItem(
            tag: 'DISHES',
            title: 'Soto Ayam',
            subtitle: 'Comforting turmeric\nchicken noodle broth.',
            imageAsset: 'assets/images/countries/indonesia/dish/soto.png',
            chipLabel: 'Soto Ayam',
            description: 'Fragrant golden soup infused with fresh turmeric, lemongrass, shredded chicken, vermicelli, and boiled egg.',
          ),
          CarouselItem(
            tag: 'DISHES',
            title: 'Gado-Gado',
            subtitle: 'Warm salad medley with\ncreamy peanut dressing.',
            imageAsset: 'assets/images/countries/indonesia/dish/gado-gado.png',
            chipLabel: 'Gado-Gado',
            description: 'Steamed vegetables, tofu, tempeh, and boiled eggs dressed in a rich sweet-and-savory spiced peanut sauce.',
          ),
        ];
    }
  }

  static List<CarouselItem> getFestivals(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'TH':
        return const [
          CarouselItem(
            tag: 'EVENTS & FESTIVALS',
            title: 'Celebrate Thailand\'s\ntraditions.',
            subtitle: 'Floating sky lanterns\nilluminating ancient skies.',
            imageAsset: 'assets/images/countries/thailand/festival/yipeng.png',
            chipLabel: 'Yi Peng & Loy Krathong',
            description: 'Magical festival where thousands of illuminated lanterns float into the night sky, releasing bad luck and welcoming fortune.',
          ),
          CarouselItem(
            tag: 'EVENTS & FESTIVALS',
            title: 'Songkran Water\nFestival.',
            subtitle: 'Nationwide joy &\ncleansing blessings.',
            imageAsset: 'assets/images/countries/thailand/festival/songkran.png',
            chipLabel: 'Songkran',
            description: 'Traditional Thai New Year celebration marked by exuberant water splashing to wash away the previous year\'s misfortunes.',
          ),
          CarouselItem(
            tag: 'EVENTS & FESTIVALS',
            title: 'Rocket Festival\nof Isan.',
            subtitle: 'Spectacular rockets\ncalling for the rains.',
            imageAsset: 'assets/images/countries/thailand/festival/bunbang.png',
            chipLabel: 'Bun Bang Fai',
            description: 'Folk celebration where towering handmade bamboo rockets are launched skyward before the rice planting season.',
          ),
          CarouselItem(
            tag: 'EVENTS & FESTIVALS',
            title: 'Ghost Festival\nof Dan Sai.',
            subtitle: 'Vibrant ghost masks\nand joyful dances.',
            imageAsset: 'assets/images/countries/thailand/festival/phita.png',
            chipLabel: 'Phi Ta Khon',
            description: 'Unique festival featuring colorful hand-painted spirit masks made from dried palm fronds and sticky rice steamers.',
          ),
          CarouselItem(
            tag: 'EVENTS & FESTIVALS',
            title: 'Chiang Mai Flower\nFestival.',
            subtitle: 'Grand floral floats &\ntropical orchids.',
            imageAsset: 'assets/images/countries/thailand/festival/chiangmai.png',
            chipLabel: 'Flower Festival',
            description: 'Three-day celebration showcasing blooming yellow chrysanthemums, tropical orchids, and musical street parades.',
          ),
        ];

      case 'VN':
        return const [
          CarouselItem(
            tag: 'EVENTS & FESTIVALS',
            title: 'Hoi An Full Moon\nLantern Night.',
            subtitle: 'Candlelit lanterns\ndrifting down the river.',
            imageAsset: 'assets/images/countries/vietnam/festival/hoilantern.png',
            chipLabel: 'Hoi An Lantern Festival',
            description: 'Every full moon, the old town turns off electricity and glows under thousands of colorful silk lanterns.',
          ),
          CarouselItem(
            tag: 'EVENTS & FESTIVALS',
            title: 'Mid-Autumn\nMoon Festival.',
            subtitle: 'Mooncakes, lion dances\nand paper lanterns.',
            imageAsset: 'assets/images/countries/vietnam/festival/fullmoon.png',
            chipLabel: 'Tet Trung Thu',
            description: 'Celebration of harvest and family with dragon dances and colorful star-shaped lanterns.',
          ),
          CarouselItem(
            tag: 'EVENTS & FESTIVALS',
            title: 'Traditional Floral\nCelebrations.',
            subtitle: 'Welcoming spring blooms\nacross ancestral pagodas.',
            imageAsset: 'assets/images/countries/vietnam/festival/hoada.png',
            chipLabel: 'Hoa Da Festival',
            description: 'Spring festivities bringing communities together to celebrate nature and renewal.',
          ),
          CarouselItem(
            tag: 'EVENTS & FESTIVALS',
            title: 'Traditional Le Hoi\nGatherings.',
            subtitle: 'Centuries of folk songs,\ngongs, and boat races.',
            imageAsset: 'assets/images/countries/vietnam/festival/lehoi.png',
            chipLabel: 'Le Hoi',
            description: 'Communal cultural gatherings commemorating legendary ancestors and historic triumphs.',
          ),
        ];

      case 'ID':
        return const [
          CarouselItem(
            tag: 'EVENTS & FESTIVALS',
            title: 'Kasanga Festival\nof Bali.',
            subtitle: 'Colossal Ogoh-Ogoh\neffigies paraded through night.',
            imageAsset: 'assets/images/countries/indonesia/festival/kasanga.png',
            chipLabel: 'Kasanga & Nyepi',
            description: 'Mesmerizing Balinese Hindu carnival of giant handmade mythological statues paraded with torchlights to purify the island before Nyepi.',
          ),
          CarouselItem(
            tag: 'EVENTS & FESTIVALS',
            title: 'Devdan Cultural\nExtravaganza.',
            subtitle: 'Acrobatic spectacle of\nthe Indonesian archipelago.',
            imageAsset: 'assets/images/countries/indonesia/festival/devdan.png',
            chipLabel: 'Devdan Show',
            description: 'Dazzling theatrical performance highlighting traditional Indonesian dance, heritage, and aerial acrobatics across Bali, Sumatra, and Papua.',
          ),
          CarouselItem(
            tag: 'EVENTS & FESTIVALS',
            title: 'Bau Nyale\nof Lombok.',
            subtitle: 'Legendary sea worm hunt\nand coastal celebration.',
            imageAsset: 'assets/images/countries/indonesia/festival/lombok.png',
            chipLabel: 'Lombok Bau Nyale',
            description: 'Ancient Sasak festival commemorating Princess Mandalika, where thousands gather on shores under starlight to catch sacred sea worms.',
          ),
          CarouselItem(
            tag: 'EVENTS & FESTIVALS',
            title: 'Ubud Food Festival\nin Bali.',
            subtitle: 'Culinary celebration of\nrich spices & traditions.',
            imageAsset: 'assets/images/countries/indonesia/festival/ubudfood.png',
            chipLabel: 'Ubud Food Fest',
            description: 'Southeast Asia\'s premier culinary event gathering master chefs, traditional spice artisans, and food lovers in cultural Ubud.',
          ),
        ];

      case 'PH':
      default:
        return const [
          CarouselItem(
            tag: 'EVENTS & FESTIVALS',
            title: 'Kasanga Festival\nof Bali.',
            subtitle: 'Colossal Ogoh-Ogoh\neffigies paraded through night.',
            imageAsset: 'assets/images/countries/indonesia/festival/kasanga.png',
            chipLabel: 'Kasanga & Nyepi',
            description: 'Mesmerizing Balinese Hindu carnival of giant handmade mythological statues paraded with torchlights to purify the island before Nyepi.',
          ),
          CarouselItem(
            tag: 'EVENTS & FESTIVALS',
            title: 'Devdan Cultural\nExtravaganza.',
            subtitle: 'Acrobatic spectacle of\nthe Indonesian archipelago.',
            imageAsset: 'assets/images/countries/indonesia/festival/devdan.png',
            chipLabel: 'Devdan Show',
            description: 'Dazzling theatrical performance highlighting traditional Indonesian dance, heritage, and aerial acrobatics across Bali, Sumatra, and Papua.',
          ),
          CarouselItem(
            tag: 'EVENTS & FESTIVALS',
            title: 'Bau Nyale\nof Lombok.',
            subtitle: 'Legendary sea worm hunt\nand coastal celebration.',
            imageAsset: 'assets/images/countries/indonesia/festival/lombok.png',
            chipLabel: 'Lombok Bau Nyale',
            description: 'Ancient Sasak festival commemorating Princess Mandalika, where thousands gather on shores under starlight to catch sacred sea worms.',
          ),
          CarouselItem(
            tag: 'EVENTS & FESTIVALS',
            title: 'Ubud Food Festival\nin Bali.',
            subtitle: 'Culinary celebration of\nrich spices & traditions.',
            imageAsset: 'assets/images/countries/indonesia/festival/ubudfood.png',
            chipLabel: 'Ubud Food Fest',
            description: 'Southeast Asia\'s premier culinary event gathering master chefs, traditional spice artisans, and food lovers in cultural Ubud.',
          ),
        ];
    }
  }
}

