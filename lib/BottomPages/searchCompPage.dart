import 'package:flutter/material.dart';
import 'package:O2ISkinSense/Otherspages/NotificationPage.dart';
import 'package:O2ISkinSense/Components/color.dart';

class ArticlePage extends StatefulWidget {
  const ArticlePage({Key? key}) : super(key: key);

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  TextEditingController _searchController = TextEditingController();
  List<String> topics = [
    "How to Treat Acne",
    "Understanding Eczema",
    "Skin Care Tips for Dry Skin",
    "Psoriasis Treatment Options",
    "Dealing with Sunburn",
    "Preventing Skin Cancer",
    // "Best Moisturizers for Sensitive Skin",
    "How to Prevent Wrinkles",
    "Diet for Healthy Skin",
    "Rosacea Management",
    "Anti-Aging Skincare Routine",
    "Natural Remedies for Skin Health",
  ];
  List<String> filteredTopics = [];

  @override
  void initState() {
    super.initState();
    filteredTopics = topics;
  }

  void _filterTopics(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTopics = topics;
      } else {
        filteredTopics = topics
            .where((topic) => topic.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            _buildModernHeader(),
            
            // Search Section
            _buildSearchSection(),
            
            // Categories or Topics
            Expanded(
              child: _buildTopicsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Skin Health",
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Learn about skin conditions",
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.notifications_outlined, color: textPrimary),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search health topics...',
            hintStyle: TextStyle(
              color: textSecondary,
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: textSecondary,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(20),
          ),
          style: TextStyle(
            color: textPrimary,
            fontSize: 16,
          ),
          onChanged: _filterTopics,
        ),
      ),
    );
  }

  Widget _buildTopicsList() {
    return filteredTopics.isEmpty 
        ? _buildEmptyState()
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ListView.builder(
              itemCount: filteredTopics.length,
              itemBuilder: (context, index) {
                return _buildTopicCard(filteredTopics[index], index);
              },
            ),
          );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 64,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 24),
          Text(
            "No topics found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Try a different search term",
            style: TextStyle(
              fontSize: 16,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(String topic, int index) {
    final colors = [primaryColor, successColor, warningColor, accentColor];
    final color = colors[index % colors.length];
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailPage(topic: topic),
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    _getImagePath(topic),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: color.withOpacity(0.1),
                        child: Icon(
                          Icons.health_and_safety,
                          color: color,
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _getTopicDescription(topic),
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTopicDescription(String topic) {
    switch (topic) {
      case "How to Treat Acne":
        return "Learn effective treatments for acne and prevent scarring";
      case "Understanding Eczema":
        return "Manage eczema symptoms and prevent flare-ups";
      case "Skin Care Tips for Dry Skin":
        return "Restore moisture and maintain healthy skin barrier";
      case "Psoriasis Treatment Options":
        return "Explore treatments for this autoimmune condition";
      case "Dealing with Sunburn":
        return "Treat sunburn and prevent future damage";
      case "Preventing Skin Cancer":
        return "Essential protection and early detection tips";
      case "How to Prevent Wrinkles":
        return "Anti-aging strategies for youthful skin";
      case "Diet for Healthy Skin":
        return "Foods that nourish and protect your skin";
      case "Rosacea Management":
        return "Control triggers and reduce inflammation";
      case "Anti-Aging Skincare Routine":
        return "Build an effective anti-aging regimen";
      case "Natural Remedies for Skin Health":
        return "Safe and effective natural treatments";
      default:
        return "Learn about this skin health topic";
    }
  }

  String _getImagePath(String topic) {
    switch (topic) {
      case "How to Treat Acne":
        return 'assets/How to Treat Acne.jpg'; // Exact match
      case "Understanding Eczema":
        return 'assets/Understanding Eczema.jpg'; // Exact match
      case "Skin Care Tips for Dry Skin":
        return 'assets/Skin Care Tips for Dry Skin.jpg'; // Exact match
      case "Psoriasis Treatment Options":
        return 'assets/Psoriasis Treatment Options.jpg'; // Exact match
      case "Dealing with Sunburn":
        return 'assets/Dealing with Sunburn.jpg'; // Exact match
      case "Preventing Skin Cancer":
        return 'assets/Preventing Skin Cancer.jpg'; // Exact match
      case "Best Moisturizers for Sensitive Skin":
        return 'assets/Best Moisturizers for Sensitive Skin.jpg'; // Exact match with proper spaces and case
      case "How to Prevent Wrinkles":
        return 'assets/How to Prevent Wrinkles.jpg'; // Exact match
      case "Diet for Healthy Skin":
        return 'assets/Diet for Healthy Skin.jpg'; // Exact match
      case "Rosacea Management":
        return 'assets/Rosacea Management.jpg'; // Exact match
      case "Anti-Aging Skincare Routine":
        return 'assets/Anti-Aging Skincare Routine.jpg'; // Exact match, no underscores
      case "Natural Remedies for Skin Health":
        return 'assets/Natural Remedies for Skin Health.jpg'; // Exact match with spaces and case
      default:
        return 'assets/Skin Care.jpg'; // Default case
    }
  }
}

class ArticleDetailPage extends StatelessWidget {
  final String topic;

  const ArticleDetailPage({Key? key, required this.topic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String articleContent = _getArticleContent(topic);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar Section
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      topic,
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      splashRadius: 20,
                      icon: Icon(Icons.notifications_active,
                          color: Colors.blue.shade900),
                      onPressed: () {
                        // Placeholder for notification functionality
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Main Image
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  _getMainImagePath(topic),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),

              // Topic Title
              Text(
                topic,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 10),

              // Brief Introduction
              Text(
                _getIntroduction(topic),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 20),

              // Detailed Content
              Text(
                articleContent,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 30),

              // Causes Section
              Text(
                'Causes:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _getCauses(topic),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 20),

              // Symptoms Section
              Text(
                'Symptoms:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _getSymptoms(topic),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 30),

              // Treatment Options
              Text(
                'Treatment Options:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _getTreatmentOptions(topic),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 30),

              // Helpful Tips
              Text(
                'Helpful Tips:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _getHelpfulTips(topic),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 30),

              // Prevention Section
              Text(
                'Prevention:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _getPrevention(topic),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 30),

              // Additional Image
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  _getSecondaryImagePath(topic),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),

              // Final Note
              Text(
                'Remember, it\'s always best to consult a dermatologist or healthcare professional for personalized advice about your skin concerns.',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),

              // When to See a Doctor
              Text(
                'When to See a Doctor:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _getWhenToSeeDoctor(topic),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // String _getMainImagePath(String topic) {
  //   switch (topic) {
  //     case "How to Treat Acne":
  //       return 'assets/acne_main.jpg';
  //     case "Understanding Eczema":
  //       return 'assets/eczema_main.jpg';
  //     case "Skin Care Tips for Dry Skin":
  //       return 'assets/dry_skin_main.jpg';
  //     case "Psoriasis Treatment Options":
  //       return 'assets/psoriasis_main.jpg';
  //     case "Dealing with Sunburn":
  //       return 'assets/sunburn_main.jpg';
  //     case "Preventing Skin Cancer":
  //       return 'assets/skin_cancer_main.jpg';
  //     case "Best Moisturizers for Sensitive Skin":
  //       return 'assets/sensitive_skin_main.jpg';
  //     case "How to Prevent Wrinkles":
  //       return 'assets/anti_aging_main.jpg';
  //     case "Diet for Healthy Skin":
  //       return 'assets/skin_diet_main.jpg';
  //     case "Rosacea Management":
  //       return 'assets/rosacea_main.jpg';
  //     case "Anti-Aging Skincare Routine":
  //       return 'assets/anti_aging_routine_main.jpg';
  //     case "Natural Remedies for Skin Health":
  //       return 'assets/natural_remedies_main.jpg';
  //     default:
  //       return 'assets/skin_care_main.jpg';
  //   }
  // }
  String _getMainImagePath(String topic) {
    switch (topic) {
      case "How to Treat Acne":
        return 'assets/How to Treat Acne.jpg'; // Exact match
      case "Understanding Eczema":
        return 'assets/Understanding Eczema.jpg'; // Exact match
      case "Skin Care Tips for Dry Skin":
        return 'assets/Skin Care Tips for Dry Skin.jpg'; // Exact match
      case "Psoriasis Treatment Options":
        return 'assets/Psoriasis Treatment Options.jpg'; // Exact match
      case "Dealing with Sunburn":
        return 'assets/Dealing with Sunburn.jpg'; // Exact match
      case "Preventing Skin Cancer":
        return 'assets/Preventing Skin Cancer.jpg'; // Exact match
      case "Best Moisturizers for Sensitive Skin":
        return 'assets/Best Moisturizers for Sensitive Skin.jpg'; // Exact match with proper spaces and case
      case "How to Prevent Wrinkles":
        return 'assets/How to Prevent Wrinkles.jpg'; // Exact match
      case "Diet for Healthy Skin":
        return 'assets/Diet for Healthy Skin.jpg'; // Exact match
      case "Rosacea Management":
        return 'assets/Rosacea Management.jpg'; // Exact match
      case "Anti-Aging Skincare Routine":
        return 'assets/Anti-Aging Skincare Routine.jpg'; // Exact match, no underscores
      case "Natural Remedies for Skin Health":
        return 'assets/Natural Remedies for Skin Health.jpg'; // Exact match with spaces and case
      default:
        return 'assets/Skin Care.jpg'; // Default case
    }
  }

  String _getSecondaryImagePath(String topic) {
    switch (topic) {
      case "How to Treat Acne":
        return 'assets/How to Treat Acne.jpg'; // Exact match
      case "Understanding Eczema":
        return 'assets/Understanding Eczema.jpg'; // Exact match
      case "Skin Care Tips for Dry Skin":
        return 'assets/Skin Care Tips for Dry Skin.jpg'; // Exact match
      case "Psoriasis Treatment Options":
        return 'assets/Psoriasis Treatment Options.jpg'; // Exact match
      case "Dealing with Sunburn":
        return 'assets/Dealing with Sunburn.jpg'; // Exact match
      case "Preventing Skin Cancer":
        return 'assets/Preventing Skin Cancer.jpg'; // Exact match
      case "Best Moisturizers for Sensitive Skin":
        return 'assets/Best Moisturizers for Sensitive Skin.jpg'; // Exact match with proper spaces and case
      case "How to Prevent Wrinkles":
        return 'assets/How to Prevent Wrinkles.jpg'; // Exact match
      case "Diet for Healthy Skin":
        return 'assets/Diet for Healthy Skin.jpg'; // Exact match
      case "Rosacea Management":
        return 'assets/Rosacea Management.jpg'; // Exact match
      case "Anti-Aging Skincare Routine":
        return 'assets/Anti-Aging Skincare Routine.jpg'; // Exact match, no underscores
      case "Natural Remedies for Skin Health":
        return 'assets/Natural Remedies for Skin Health.jpg'; // Exact match with spaces and case
      default:
        return 'assets/Skin Care.jpg'; // Default case
    }
  }

  String _getIntroduction(String topic) {
    switch (topic) {
      case "How to Treat Acne":
        return "Acne is one of the most common skin conditions affecting people of all ages. This comprehensive guide covers everything from causes to advanced treatment options.";
      case "Understanding Eczema":
        return "Eczema, or atopic dermatitis, is a chronic condition that requires careful management. Learn about the latest approaches to controlling flare-ups and maintaining healthy skin.";
      case "Skin Care Tips for Dry Skin":
        return "Dry skin can be uncomfortable and even painful. Discover the best practices and products to restore moisture and maintain your skin's natural barrier.";
      case "Psoriasis Treatment Options":
        return "Psoriasis is more than just a skin condition - it's an immune system disorder. Explore the various treatment options available today.";
      case "Dealing with Sunburn":
        return "Sunburn is not just painful - it can cause long-term damage. Learn how to treat sunburn effectively and prevent future occurrences.";
      case "Preventing Skin Cancer":
        return "Skin cancer is one of the most preventable forms of cancer. This guide provides essential information on protection and early detection.";
      case "Best Moisturizers for Sensitive Skin":
        return "Finding the right moisturizer for sensitive skin can be challenging. We've researched the best options that soothe without irritation.";
      case "How to Prevent Wrinkles":
        return "While wrinkles are a natural part of aging, there are effective ways to minimize their appearance. Discover science-backed prevention strategies.";
      case "Diet for Healthy Skin":
        return "What you eat significantly impacts your skin's health. Learn about the nutrients your skin needs and the foods that provide them.";
      case "Rosacea Management":
        return "Rosacea is a chronic inflammatory skin condition. This guide covers triggers to avoid and effective management strategies.";
      case "Anti-Aging Skincare Routine":
        return "An effective anti-aging routine can help maintain youthful skin. Learn about the essential steps and products for every age.";
      case "Natural Remedies for Skin Health":
        return "Nature offers many solutions for common skin concerns. Discover safe and effective natural remedies backed by science.";
      default:
        return "Learn everything you need to know about this important skin health topic.";
    }
  }

  String _getArticleContent(String topic) {
    switch (topic) {
      case "How to Treat Acne":
        return "Acne vulgaris is a skin condition that occurs when hair follicles become clogged with oil and dead skin cells. It commonly appears on the face, forehead, chest, upper back and shoulders. Acne can be inflammatory (red, swollen pimples) or non-inflammatory (blackheads and whiteheads). The severity ranges from mild (a few occasional pimples) to severe cystic acne (large, painful nodules).\n\nAcne typically begins during puberty when the sebaceous glands activate, but it can occur at any age. Hormonal changes, certain medications, diet, and stress can all contribute to acne development. While not dangerous, acne can cause emotional distress and lead to scarring if not treated properly.";
      case "Understanding Eczema":
        return "Eczema (atopic dermatitis) is a condition that makes your skin red and itchy. It's common in children but can occur at any age. Eczema is chronic and tends to flare periodically. It may be accompanied by asthma or hay fever.\n\nThe exact cause of eczema is unknown, but it's believed to develop due to a combination of genetic and environmental factors. People with eczema may have an overactive immune system that responds aggressively when triggered by irritants outside or inside the body. The skin of people with eczema has difficulty retaining moisture and protecting against bacteria, irritants and allergens.\n\nEczema symptoms vary widely from person to person and can change over time. Common symptoms include dry, sensitive skin; intense itching; red, inflamed skin; recurring rash; scaly areas; rough, leathery patches; oozing or crusting; and areas of swelling.";
      case "Skin Care Tips for Dry Skin":
        return "Dry skin (xerosis) is a common condition that can affect anyone, though it becomes more prevalent with age. When skin loses too much water and oil, it becomes dry, leading to flaking, itching, cracking and sometimes even bleeding.\n\nEnvironmental factors are the most common cause of dry skin. These include cold or dry weather, sun exposure, harsh soaps, hot showers, and indoor heating. Certain medical conditions like hypothyroidism, diabetes, malnutrition, and skin conditions such as eczema and psoriasis can also cause dry skin.\n\nDry skin needs special care to restore moisture and prevent further water loss. The key is to use gentle cleansers, apply moisturizers frequently (especially right after bathing), and avoid anything that strips moisture from the skin. For severe cases, medical treatments may be necessary.";
      case "Psoriasis Treatment Options":
        return "Psoriasis is a chronic autoimmune condition that causes the rapid buildup of skin cells. This buildup leads to scaling on the skin's surface, inflammation, and redness. The most common form, plaque psoriasis, appears as raised, red patches covered with a silvery white buildup of dead skin cells.\n\nPsoriasis occurs when the immune system mistakes healthy skin cells for pathogens and attacks them. This causes the skin cell production process to go into overdrive. New skin cells move to the outermost layer of skin in days rather than weeks. The cells build up and form thick, scaly patches.\n\nPsoriasis tends to go through cycles, flaring for a few weeks or months, then subsiding for a time. Triggers vary by individual but may include infections, skin injuries, stress, smoking, heavy alcohol consumption, vitamin D deficiency, and certain medications.";
      case "Dealing with Sunburn":
        return "Sunburn is the skin's reaction to excessive exposure to ultraviolet (UV) radiation from the sun or artificial sources like tanning beds. The skin becomes red, painful, and may swell or blister. Sunburn can occur in as little as 15 minutes but the full effects may not be visible for several hours.\n\nUV radiation damages the DNA in skin cells. The body responds by increasing blood flow to the affected areas, causing the characteristic redness. In severe cases, the immune system triggers inflammation that can lead to blistering and peeling as the body tries to rid itself of damaged cells.\n\nWhile sunburn symptoms are usually temporary, the skin damage is cumulative and can lead to premature aging (wrinkles, age spots) and increased risk of skin cancer. Repeated sunburns, especially in childhood, significantly increase melanoma risk.";
      case "Preventing Skin Cancer":
        return "Skin cancer is the abnormal growth of skin cells, most often caused by UV radiation from sunlight or tanning beds. There are three main types: basal cell carcinoma (most common, least dangerous), squamous cell carcinoma, and melanoma (most dangerous).\n\nUV radiation damages the DNA in skin cells. Normally, this damage is repaired or the cells die. But when the damage affects the DNA of genes that control skin cell growth, skin cancer can develop. Risk factors include fair skin, history of sunburns, excessive sun exposure, sunny or high-altitude climates, moles, precancerous skin lesions, family history, weakened immune system, and exposure to radiation or certain substances.\n\nEarly detection is crucial, especially for melanoma which can spread quickly. Regular self-exams and professional skin checks can catch skin cancer early when it's most treatable.";
      case "Best Moisturizers for Sensitive Skin":
        return "Sensitive skin reacts more easily to irritants than normal skin. It may become red, itchy, or develop rashes in response to products, weather changes, or stress. People with sensitive skin often have a weaker skin barrier, allowing irritants to penetrate more easily and moisture to escape.\n\nThe best moisturizers for sensitive skin should be fragrance-free, hypoallergenic, and contain soothing ingredients. Look for products with ceramides to repair the skin barrier, hyaluronic acid for hydration, and niacinamide to reduce redness. Avoid products with alcohol, synthetic fragrances, harsh preservatives, or too many active ingredients.\n\nApplication technique matters too. Apply moisturizer to damp skin to lock in hydration. Use gentle patting motions rather than rubbing. Test new products on a small area before full-face application.";
      case "How to Prevent Wrinkles":
        return "Wrinkles are creases, folds or ridges in the skin that naturally appear as we age. The first wrinkles tend to appear on parts of the body that receive the most sun exposure, especially the face, neck, backs of hands, and arms.\n\nSkin aging occurs through two processes: intrinsic (chronological) aging and extrinsic (environmental) aging. Intrinsic aging is inevitable and involves thinning skin, decreased collagen production, and reduced elasticity. Extrinsic aging is caused by external factors like sun exposure (photoaging), pollution, smoking, and repetitive facial expressions.\n\nWhile we can't stop intrinsic aging, we can significantly slow extrinsic aging. A comprehensive anti-aging strategy includes sun protection, antioxidants, retinoids, proper hydration, and a healthy lifestyle. Starting prevention early yields the best long-term results.";
      case "Diet for Healthy Skin":
        return "Your skin is a reflection of your overall health, and what you eat significantly impacts its appearance and function. Certain nutrients help build and protect skin cells, fight inflammation, and maintain hydration.\n\nKey nutrients for skin health include:\n- Vitamin C for collagen production\n- Vitamin E as an antioxidant\n- Omega-3 fatty acids to maintain the skin barrier\n- Vitamin A for cell turnover\n- Zinc for wound healing\n- Selenium for protection against UV damage\n- Antioxidants to combat free radicals\n\nA skin-healthy diet emphasizes fruits, vegetables, whole grains, lean proteins, and healthy fats. Stay hydrated with water and limit processed foods, sugar, and excessive alcohol which can accelerate aging. Some research suggests dairy and high-glycemic foods may exacerbate acne for some people.";
      case "Rosacea Management":
        return "Rosacea is a chronic inflammatory skin condition that primarily affects the face. It causes redness, visible blood vessels, and sometimes small, red, pus-filled bumps. Rosacea typically begins after age 30 and tends to flare up periodically.\n\nThe exact cause is unknown but likely involves a combination of hereditary and environmental factors. Triggers vary but may include hot drinks, spicy foods, alcohol, temperature extremes, sunlight, stress, certain medications, and skin care products. Unlike acne, rosacea isn't caused by poor hygiene.\n\nRosacea has four subtypes with different symptoms: erythematotelangiectatic (flushing and redness), papulopustular (acne-like breakouts), phymatous (thickened skin), and ocular (eye irritation). Treatment focuses on controlling symptoms through trigger avoidance, gentle skin care, medications, and sometimes laser therapy.";
      case "Anti-Aging Skincare Routine":
        return "An effective anti-aging skincare routine should address multiple aspects of skin aging: wrinkles, loss of elasticity, uneven tone, and dryness. The best approach combines prevention, protection, and repair.\n\nCore components of an anti-aging routine:\n1. Cleanser: Gentle, non-stripping formula\n2. Antioxidant serum: Vitamin C is gold standard\n3. Retinoid: Gold standard for collagen production\n4. Moisturizer: Hydration is key for plump skin\n5. Sunscreen: Daily SPF 30+ is non-negotiable\n\nAdditional beneficial ingredients include hyaluronic acid for hydration, niacinamide for barrier repair, peptides for collagen support, and alpha hydroxy acids for exfoliation. Consistency is crucial - most anti-aging products take weeks to months to show effects. Start simple and add products gradually.";
      case "Natural Remedies for Skin Health":
        return "Many natural ingredients have scientifically proven benefits for skin health. While not replacements for medical treatments, they can be effective for mild concerns and maintenance.\n\nEvidence-backed natural remedies include:\n- Aloe vera: Soothes burns and moisturizes\n- Green tea: Antioxidant and anti-inflammatory\n- Honey: Antibacterial and wound-healing\n- Coconut oil: Moisturizing (but may clog pores)\n- Oatmeal: Soothes itchy, irritated skin\n- Tea tree oil: Antimicrobial (must be diluted)\n\nImportant considerations when using natural remedies:\n- Natural doesn't always mean safe or non-irritating\n- Proper preparation and storage is crucial\n- Patch test first to check for reactions\n- Know when professional treatment is needed\n- Some natural ingredients interact with medications\n\nFor best results, combine natural remedies with a solid basic skincare routine of cleansing, moisturizing, and sun protection.";
      default:
        return "This comprehensive guide provides detailed information about $topic. The condition affects many people and understanding its causes, symptoms, and treatment options is essential for proper management. With the right approach, most skin conditions can be effectively controlled or treated. The key is to identify triggers, follow a consistent care routine, and seek professional help when needed.";
    }
  }

  String _getCauses(String topic) {
    switch (topic) {
      case "How to Treat Acne":
        return "• Excess oil (sebum) production\n• Hair follicles clogged by oil and dead skin cells\n• Bacteria (Propionibacterium acnes)\n• Excess androgen activity (hormones)\n• Certain medications (corticosteroids, lithium)\n• Diet (high glycemic foods, dairy in some people)\n• Stress (can worsen existing acne)";
      case "Understanding Eczema":
        return "• Genetic predisposition\n• Immune system dysfunction\n• Skin barrier defects\n• Environmental triggers (irritants, allergens)\n• Stress (can trigger flare-ups)\n• Temperature extremes\n• Microbial factors (certain bacteria on skin)";
      case "Skin Care Tips for Dry Skin":
        return "• Environmental factors (low humidity, cold weather)\n• Hot showers or baths\n• Harsh soaps and detergents\n• Aging (natural oil production decreases)\n• Certain medical conditions (hypothyroidism, diabetes)\n• Medications (diuretics, retinoids)\n• Nutritional deficiencies";
      case "Psoriasis Treatment Options":
        return "• Immune system disorder (T cells attack healthy skin)\n• Genetic predisposition\n• Environmental triggers (infections, skin injury)\n• Stress\n• Smoking and alcohol consumption\n• Certain medications (lithium, beta blockers)\n• Vitamin D deficiency";
      case "Dealing with Sunburn":
        return "• UV radiation from sun or tanning beds\n• Lack of proper sun protection\n• Fair skin (less melanin protection)\n• Certain medications increase photosensitivity\n• High altitude (stronger UV radiation)\n• Reflection from water, sand, or snow\n• Ozone layer depletion in some regions";
      case "Preventing Skin Cancer":
        return "• UV radiation (sun exposure, tanning beds)\n• Fair skin, light eyes, red or blond hair\n• History of sunburns\n• Living in sunny or high-altitude climates\n• Moles (especially atypical)\n• Weakened immune system\n• Exposure to radiation or certain chemicals\n• Family history of skin cancer";
      case "Best Moisturizers for Sensitive Skin":
        return "• Genetic predisposition\n• Impaired skin barrier function\n• Environmental factors (pollution, weather)\n• Overuse of harsh skincare products\n• Stress\n• Hormonal changes\n• Underlying skin conditions (eczema, rosacea)";
      case "How to Prevent Wrinkles":
        return "• Natural aging process (decreased collagen)\n• Sun exposure (photoaging)\n• Smoking\n• Pollution\n• Repetitive facial expressions\n• Poor nutrition\n• Dehydration\n• Sleep position (sleep wrinkles)";
      case "Diet for Healthy Skin":
        return "• Nutrient deficiencies (vitamins A, C, E, etc.)\n• High sugar intake (glycation damages collagen)\n• Processed foods (lack essential nutrients)\n• Dehydration\n• Food intolerances (may cause inflammation)\n• Excessive alcohol consumption\n• Low antioxidant intake";
      case "Rosacea Management":
        return "• Abnormalities in facial blood vessels\n• Demodex mites (may play a role)\n• Helicobacter pylori bacteria\n• Genetic predisposition\n• Immune system factors\n• Environmental triggers (sun, stress, etc.)\n• Certain medications (vasodilators)";
      case "Anti-Aging Skincare Routine":
        return "• Intrinsic aging (chronological)\n• Extrinsic aging (sun exposure, pollution)\n• Decreased collagen and elastin production\n• Slower cell turnover\n• Reduced natural oil production\n• Free radical damage\n• Glycation (sugar damaging proteins)";
      case "Natural Remedies for Skin Health":
        return "• Desire to avoid synthetic ingredients\n• Sensitivity to conventional products\n• Cultural or personal preferences\n• Complementary approach to medical treatments\n• Accessibility in some regions\n• Historical/traditional use\n• Holistic health philosophy";
      default:
        return "The causes vary but may include genetic factors, environmental triggers, immune system responses, lifestyle factors, and natural aging processes.";
    }
  }

  String _getSymptoms(String topic) {
    switch (topic) {
      case "How to Treat Acne":
        return "• Whiteheads (closed plugged pores)\n• Blackheads (open plugged pores)\n• Small red, tender bumps (papules)\n• Pimples (pustules)\n• Large, solid, painful lumps (nodules)\n• Painful, pus-filled lumps (cystic lesions)\n• Oily skin\n• Possible scarring";
      case "Understanding Eczema":
        return "• Dry, sensitive skin\n• Intense itching (often worse at night)\n• Red or brownish-gray patches\n• Small, raised bumps (may leak fluid)\n• Thickened, cracked, scaly skin\n• Raw, swollen skin from scratching\n• Common locations: hands, feet, wrists, neck, eyelids";
      case "Skin Care Tips for Dry Skin":
        return "• Skin tightness (especially after bathing)\n• Rough texture\n• Itching (pruritus)\n• Flaking, scaling or peeling\n• Fine lines or cracks\n• Gray, ashy skin (in darker skin tones)\n• Redness\n• Deep cracks that may bleed";
      case "Psoriasis Treatment Options":
        return "• Red patches of skin with thick scales\n• Dry, cracked skin that may bleed\n• Itching, burning or soreness\n• Thickened, pitted or ridged nails\n• Swollen and stiff joints (psoriatic arthritis)\n• Plaques may range from small to large areas";
      case "Dealing with Sunburn":
        return "• Pinkness or redness\n• Skin feels warm or hot to touch\n• Pain, tenderness and itching\n• Swelling\n• Small fluid-filled blisters\n• Headache, fever, nausea (if severe)\n• Peeling skin several days later";
      case "Preventing Skin Cancer":
        return "• New growth or sore that doesn't heal\n• Change in existing mole (size, color, shape)\n• Pearly or waxy bump\n• Flat, flesh-colored or brown scar-like lesion\n• Firm, red nodule\n• Flat lesion with scaly, crusted surface\n• Itching, tenderness or pain in lesion";
      case "Best Moisturizers for Sensitive Skin":
        return "• Redness\n• Burning or stinging sensation\n• Tightness\n• Itching\n• Dry patches\n• Reacts to many products\n• Flare-ups from weather changes\n• Rash or hives after product use";
      case "How to Prevent Wrinkles":
        return "• Fine lines (especially around eyes and mouth)\n• Deeper furrows (forehead, between brows)\n• Loose or sagging skin\n• Dry, rough texture\n• Uneven skin tone\n• Age spots (sun spots)\n• Loss of facial volume";
      case "Diet for Healthy Skin":
        return "• Dull complexion\n• Dryness or oiliness\n• Premature aging signs\n• Slow wound healing\n• Increased sensitivity\n• Breakouts or rashes\n• Dark circles under eyes\n• Loss of elasticity";
      case "Rosacea Management":
        return "• Facial redness (especially center of face)\n• Visible blood vessels (telangiectasia)\n• Swollen red bumps (may resemble acne)\n• Eye problems (dryness, irritation)\n• Burning or stinging sensation\n• Dry, rough, or scaly appearance\n• Enlarged nose (rhinophyma in severe cases)";
      case "Anti-Aging Skincare Routine":
        return "• Fine lines and wrinkles\n• Loss of firmness (sagging)\n• Uneven skin tone (hyperpigmentation)\n• Rough texture\n• Enlarged pores\n• Dull complexion\n• Thin, transparent skin\n• Easy bruising";
      case "Natural Remedies for Skin Health":
        return "• Varies by remedy and skin concern\n• May include redness reduction\n• Improved hydration\n• Soothing of irritation\n• Brighter complexion\n• Reduced inflammation\n• Mild exfoliation\n• Antibacterial effects";
      default:
        return "Symptoms vary but may include redness, itching, dryness, inflammation, visible changes in skin texture or color, and discomfort or pain in affected areas.";
    }
  }

  String _getTreatmentOptions(String topic) {
    switch (topic) {
      case "How to Treat Acne":
        return "• Topical treatments: Benzoyl peroxide, salicylic acid, retinoids, antibiotics\n• Oral medications: Antibiotics, hormonal therapies, isotretinoin (for severe cases)\n• Therapies: Light therapy, chemical peels, extraction of comedones\n• Lifestyle: Gentle cleansing, oil-free products, stress management\n• Professional procedures: Laser therapy, microdermabrasion\n• For scars: Microneedling, fillers, laser resurfacing";
      case "Understanding Eczema":
        return "• Moisturizers: Apply multiple times daily, especially after bathing\n• Topical corticosteroids: For flare-ups (varying strengths)\n• Other topical medications: Calcineurin inhibitors, PDE4 inhibitors\n• Oral medications: Antihistamines, antibiotics (if infected)\n• Light therapy: UV therapy under medical supervision\n• Wet wrap therapy: For severe cases\n• Stress management: Can help prevent flare-ups";
      case "Skin Care Tips for Dry Skin":
        return "• Moisturizers: Thick, ointment-based for very dry skin\n• Humidifiers: Add moisture to indoor air\n• Bathing habits: Short, lukewarm showers; gentle cleansers\n• Avoid irritants: Harsh soaps, fragrances, wool clothing\n• Medications: Prescription creams for severe cases\n• Dietary changes: Increase omega-3 fatty acids\n• Protection: Gloves for washing dishes, cold weather";
      case "Psoriasis Treatment Options":
        return "• Topical treatments: Corticosteroids, vitamin D analogs, retinoids\n• Light therapy: UVB phototherapy, excimer laser\n• Oral medications: Methotrexate, cyclosporine, biologics\n• Lifestyle: Stress reduction, avoid triggers\n• Alternative therapies: Aloe vera, fish oil supplements (may help mild cases)\n• Comorbidities management: Address associated conditions";
      case "Dealing with Sunburn":
        return "• Cool compresses: Soothe burned skin\n• Moisturizers: Aloe vera or hydrocortisone cream\n• Hydration: Drink extra water\n• Pain relief: NSAIDs like ibuprofen\n• Avoid further sun exposure: Until fully healed\n• Don't pop blisters: Let them heal naturally\n• Medical care: For severe cases with fever or extensive blistering";
      case "Preventing Skin Cancer":
        return "• Surgical excision: Removes cancerous tissue\n• Mohs surgery: Layer-by-layer removal for precise treatment\n• Cryotherapy: Freezes precancerous cells\n• Topical treatments: For certain precancers\n• Radiation therapy: For areas hard to treat surgically\n• Chemotherapy: For advanced cases\n• Immunotherapy: Boosts immune response against cancer";
      case "Best Moisturizers for Sensitive Skin":
        return "• Ingredients to look for: Ceramides, hyaluronic acid, colloidal oatmeal\n• Fragrance-free: Avoid synthetic and natural fragrances\n• Texture: Creams often better than lotions\n• Application: Apply to damp skin, pat don't rub\n• Patch test: New products on small area first\n• Minimal ingredients: Fewer components mean fewer potential irritants\n• Avoid common irritants: Alcohol, essential oils, harsh preservatives";
      case "How to Prevent Wrinkles":
        return "• Sun protection: Broad-spectrum SPF 30+ daily\n• Topical retinoids: Gold standard for collagen production\n• Antioxidants: Vitamin C serums combat free radicals\n• Moisturize: Hydrated skin looks plumper\n• Healthy lifestyle: Don't smoke, limit alcohol, manage stress\n• Sleep: Quality sleep allows skin repair\n• Professional treatments: Chemical peels, laser resurfacing";
      case "Diet for Healthy Skin":
        return "• Antioxidant-rich foods: Berries, leafy greens, nuts\n• Healthy fats: Avocados, olive oil, fatty fish\n• Hydration: Water, herbal teas\n• Collagen support: Vitamin C foods, bone broth\n• Zinc sources: Shellfish, legumes, seeds\n• Probiotics: Yogurt, kefir, fermented foods\n• Limit: Sugar, processed foods, excessive alcohol";
      case "Rosacea Management":
        return "• Topical medications: Brimonidine, ivermectin, azelaic acid\n• Oral antibiotics: Doxycycline, tetracycline\n• Laser therapy: Reduces visible blood vessels\n• Trigger avoidance: Identify and minimize personal triggers\n• Gentle skincare: Avoid irritating products\n• Eye care: For ocular rosacea\n• Lifestyle: Stress management, sun protection";
      case "Anti-Aging Skincare Routine":
        return "• Morning: Cleanse, antioxidant serum, moisturizer with SPF\n• Evening: Cleanse, retinoid, nourishing moisturizer\n• Weekly: Exfoliation (AHAs/BHAs), treatment masks\n• Professional treatments: Consider periodic facials\n• Eye care: Specialized eye creams\n• Neck and décolletage: Extend routine to these areas\n• Consistency: Daily commitment yields best results";
      case "Natural Remedies for Skin Health":
        return "• Honey: Antibacterial, wound healing\n• Aloe vera: Soothes burns, moisturizes\n• Green tea: Antioxidant, anti-inflammatory\n• Oatmeal: Calms itchy skin\n• Coconut oil: Moisturizing (caution with acne-prone)\n• Tea tree oil: Antimicrobial (must dilute)\n• Rosehip oil: Vitamin A for scar reduction\n• Always patch test natural remedies first";
      default:
        return "Treatment options vary depending on the specific condition and severity, ranging from topical applications and oral medications to lifestyle changes and professional procedures. Consultation with a dermatologist is recommended for personalized treatment plans.";
    }
  }

  String _getHelpfulTips(String topic) {
    switch (topic) {
      case "How to Treat Acne":
        return "• Wash face gently twice daily and after sweating\n• Use fingertips to apply cleanser (not washcloths or sponges)\n• Shampoo regularly, especially if oily\n• Let skin heal naturally - don't pick or pop pimples\n• Keep hands off your face\n• Clean phone screens and pillowcases regularly\n• Give treatments 4-8 weeks to work before switching";
      case "Understanding Eczema":
        return "• Identify and avoid personal triggers\n• Keep fingernails short to minimize damage from scratching\n• Use fragrance-free laundry detergent\n• Wear soft, breathable fabrics like cotton\n• Manage stress through relaxation techniques\n• Bathe in lukewarm (not hot) water\n• Apply moisturizer within 3 minutes after bathing";
      case "Skin Care Tips for Dry Skin":
        return "• Apply moisturizer immediately after bathing\n• Use humidifiers in dry climates/seasons\n• Wear gloves when using cleaning products\n• Choose fragrance-free, dye-free products\n• Avoid sitting directly in front of heat sources\n• Pat (don't rub) skin dry after washing\n• Drink plenty of water to hydrate from within";
      case "Psoriasis Treatment Options":
        return "• Moisturize daily to reduce scaling\n• Soak in oatmeal or Epsom salt baths\n• Get small amounts of sunlight (with doctor's approval)\n• Manage stress through meditation or yoga\n• Join a support group for emotional support\n• Cover lesions when going out in cold weather\n• Avoid scratching to prevent Koebner phenomenon";
      case "Dealing with Sunburn":
        return "• Start treatment as soon as you notice sunburn\n• Wear loose, soft clothing over burned areas\n• Stay in the shade until skin heals completely\n• Reapply aloe vera or moisturizer frequently\n• Take cool (not cold) baths for relief\n• Use extra sunscreen after healing (skin more sensitive)\n• Consider taking antioxidant supplements for future protection";
      case "Preventing Skin Cancer":
        return "• Perform monthly skin self-exams\n• Get professional skin checks annually\n• Apply sunscreen 30 minutes before sun exposure\n• Reapply sunscreen every 2 hours and after swimming\n• Seek shade between 10am-4pm when UV is strongest\n• Wear UPF clothing and wide-brimmed hats\n• Don't use tanning beds - opt for self-tanners instead";
      case "Best Moisturizers for Sensitive Skin":
        return "• Keep a product diary to identify irritants\n• Introduce new products one at a time\n• Store products properly to maintain stability\n• Wash hands before applying products\n• Use clean applicators (not fingers) for jar products\n• Look for National Eczema Association approved products\n• When in doubt, simpler formulations are often better";
      case "How to Prevent Wrinkles":
        return "• Always wear sunglasses to prevent squinting\n• Sleep on your back to avoid sleep wrinkles\n• Use a humidifier to prevent environmental drying\n• Incorporate facial massage to boost circulation\n• Eat collagen-supporting nutrients (vitamin C, proline)\n• Consider silk pillowcases to reduce friction\n• Manage stress to prevent stress-related aging";
      case "Diet for Healthy Skin":
        return "• Eat a rainbow of colorful fruits and vegetables\n• Include healthy fats with every meal\n• Choose whole foods over processed options\n• Drink herbal teas for added antioxidants\n• Snack on nuts and seeds for skin-healthy nutrients\n• Limit caffeine and alcohol which can dehydrate\n• Cook with skin-friendly herbs like turmeric";
      case "Rosacea Management":
        return "• Keep a trigger diary to identify patterns\n• Cool face with thermal water spray during flare-ups\n• Apply green-tinted makeup to counteract redness\n• Use mineral sunscreens (less irritating)\n• Avoid extreme temperature changes\n• Blot (don't rub) face with soft towels\n• Choose alcohol-free, non-astringent products";
      case "Anti-Aging Skincare Routine":
        return "• Start anti-aging prevention in your 20s\n• Be patient - results take weeks to months\n• Don't over-exfoliate (2-3 times weekly max)\n• Extend skincare to neck and hands\n• Layer products from thinnest to thickest\n• Store vitamin C and retinoids properly (away from light)\n• Adjust routine seasonally as skin needs change";
      case "Natural Remedies for Skin Health":
        return "• Research proper preparation methods\n• Store natural remedies correctly (some need refrigeration)\n• Know when to seek professional help\n• Combine with basic skincare (cleansing, moisturizing)\n• Be cautious with essential oils (always dilute)\n• Consider organic options to avoid pesticides\n• Monitor for any adverse reactions\n• Understand limitations - some conditions need medical treatment";
      default:
        return "• Be consistent with your skincare routine\n• Patch test new products before full application\n• Protect your skin from sun damage daily\n• Stay hydrated by drinking plenty of water\n• Manage stress through healthy coping mechanisms\n• Get adequate sleep for skin repair\n• Consult a dermatologist for persistent concerns";
    }
  }

  String _getPrevention(String topic) {
    switch (topic) {
      case "How to Treat Acne":
        return "• Wash face twice daily and after sweating\n• Use non-comedogenic hair and skincare products\n• Avoid touching your face throughout the day\n• Shower after strenuous activities\n• Manage stress through healthy outlets\n• Consider dietary modifications if certain foods trigger breakouts\n• Change pillowcases regularly";
      case "Understanding Eczema":
        return "• Identify and avoid personal triggers\n• Maintain consistent moisturizing routine\n• Use gentle, fragrance-free products\n• Wear soft, breathable fabrics\n• Manage indoor humidity levels\n• Practice stress-reduction techniques\n• Keep nails short to minimize scratching damage";
      case "Skin Care Tips for Dry Skin":
        return "• Apply moisturizer immediately after bathing\n• Use humidifiers in dry environments\n• Wear gloves in cold weather and when washing dishes\n• Choose mild, fragrance-free cleansers\n• Limit bath/shower time and use lukewarm water\n• Stay hydrated by drinking plenty of water\n• Protect skin from harsh weather conditions";
      case "Psoriasis Treatment Options":
        return "• Manage stress through relaxation techniques\n• Avoid skin injuries (cuts, scrapes, sunburn)\n• Treat infections promptly\n• Maintain healthy weight and lifestyle\n• Limit alcohol consumption\n• Don't smoke\n• Get appropriate sunlight exposure (with doctor's guidance)";
      case "Dealing with Sunburn":
        return "• Apply broad-spectrum SPF 30+ sunscreen daily\n• Reapply sunscreen every 2 hours and after swimming\n• Seek shade during peak sun hours (10am-4pm)\n• Wear protective clothing, hats and sunglasses\n• Avoid tanning beds\n• Be extra cautious near water, snow and sand\n• Check UV index before outdoor activities";
      case "Preventing Skin Cancer":
        return "• Practice sun safety year-round\n• Perform regular skin self-exams\n• Get professional skin checks annually\n• Know your family history of skin cancer\n• Be extra cautious if you have many moles\n• Protect children from sun damage\n• Choose sun-protective clothing with UPF rating";
      case "Best Moisturizers for Sensitive Skin":
        return "• Patch test all new products\n• Stick to fragrance-free formulations\n• Avoid products with common irritants\n• Introduce one new product at a time\n• Keep skincare routine simple\n• Be cautious with active ingredients\n• Store products properly to maintain stability";
      case "How to Prevent Wrinkles":
        return "• Wear sunscreen daily, even on cloudy days\n• Don't smoke and limit alcohol consumption\n• Stay hydrated by drinking plenty of water\n• Eat antioxidant-rich diet\n• Get adequate quality sleep\n• Manage stress through healthy outlets\n• Use retinoids as preventive measure (with dermatologist guidance)";
      case "Diet for Healthy Skin":
        return "• Eat variety of colorful fruits and vegetables\n• Include healthy fats in your diet\n• Stay hydrated with water and herbal teas\n• Limit processed foods and added sugars\n• Choose whole grains over refined carbohydrates\n• Include protein sources with amino acids for collagen\n• Consider probiotic foods for gut-skin connection";
      case "Rosacea Management":
        return "• Identify and avoid personal triggers\n• Protect skin from sun exposure\n• Manage stress through relaxation techniques\n• Avoid extreme temperatures\n• Choose gentle, non-irritating skincare\n• Be cautious with exercise (don't overheat)\n• Limit alcohol consumption";
      case "Anti-Aging Skincare Routine":
        return "• Start sun protection early in life\n• Establish consistent skincare routine\n• Don't skip nighttime skincare\n• Get adequate sleep for cellular repair\n• Manage stress to prevent stress-related aging\n• Avoid repetitive facial movements\n• Stay hydrated inside and out";
      case "Natural Remedies for Skin Health":
        return "• Research proper use of natural ingredients\n• Understand potential interactions\n• Know when professional treatment is needed\n• Combine with evidence-based practices\n• Store natural remedies properly\n• Be aware of expiration dates\n• Consider organic options to avoid pesticides";
      default:
        return "• Practice sun protection daily\n• Maintain consistent skincare routine\n• Stay hydrated by drinking plenty of water\n• Eat balanced diet rich in antioxidants\n• Get regular exercise for circulation\n• Manage stress through healthy outlets\n• Avoid smoking and limit alcohol\n• Get adequate sleep for skin repair";
    }
  }

  String _getWhenToSeeDoctor(String topic) {
    switch (topic) {
      case "How to Treat Acne":
        return "• If over-the-counter treatments fail after 2-3 months\n• If acne is severe (many inflamed nodules/cysts)\n• If acne is causing significant distress or scarring\n• If dark spots persist after pimples heal\n• If you suspect hormonal causes (irregular periods, excess hair growth)\n• If experiencing side effects from acne medications";
      case "Understanding Eczema":
        return "• If eczema covers large areas of body\n• If skin becomes infected (yellow crust, pus, increasing pain)\n• If eczema interferes with daily activities or sleep\n• If over-the-counter treatments aren't helping\n• If eczema worsens despite treatment\n• If you develop eye problems (redness, pain)";
      case "Skin Care Tips for Dry Skin":
        return "• If skin cracks and bleeds\n• If you develop signs of infection (redness, swelling, pus)\n• If dry skin persists despite good care\n• If you have associated symptoms (fatigue, weight changes)\n• If rash develops or spreads\n• If over-the-counter products cause irritation";
      case "Psoriasis Treatment Options":
        return "• If psoriasis covers large areas of body\n• If joints become painful or swollen\n• If symptoms significantly impact quality of life\n• If treatments stop working\n• If you develop fever or feel ill with flare-up\n• If nails become thickened or separated from nail bed";
      case "Dealing with Sunburn":
        return "• If sunburn covers large portion of body\n• If blisters cover more than 20% of body\n• If experiencing fever, chills or confusion\n• If severe pain persists beyond 48 hours\n• If signs of infection develop (increasing redness, pus)\n• If sunburn doesn't start improving after a few days";
      case "Preventing Skin Cancer":
        return "• If you notice new or changing skin growth\n• If mole changes in size, shape or color\n• If sore doesn't heal within 2 weeks\n• If spot becomes painful, itchy or bleeds\n• If you have many moles or family history of melanoma\n• For annual skin cancer screening if high risk";
      case "Best Moisturizers for Sensitive Skin":
        return "• If skin reacts badly to multiple products\n• If persistent redness or irritation occurs\n• If rash spreads or worsens\n• If experiencing burning or stinging with products\n• If over-the-counter options don't help\n• If you suspect contact dermatitis";
      case "How to Prevent Wrinkles":
        return "• If concerned about premature aging\n• For personalized anti-aging treatment plan\n• If considering cosmetic procedures\n• For evaluation of deep wrinkles or volume loss\n• If experiencing unusual skin changes with aging\n• For prescription-strength anti-aging treatments";
      case "Diet for Healthy Skin":
        return "• If skin issues persist despite dietary changes\n• If suspecting food allergies/sensitivities\n• For nutritional deficiency evaluation\n• If experiencing acne that may be diet-related\n• For guidance on supplements for skin health\n• If skin condition affects quality of life";
      case "Rosacea Management":
        return "• If rosacea symptoms worsen\n• If eyes become irritated or vision changes\n• If over-the-counter treatments don't help\n• If skin becomes thickened (especially nose)\n• For prescription treatment options\n• If rosacea affects self-esteem or quality of life";
      case "Anti-Aging Skincare Routine":
        return "• For personalized anti-aging assessment\n• If considering medical-grade treatments\n• For prescription retinoid consultation\n• If experiencing premature aging signs\n• For evaluation of age spots or uneven texture\n• If over-the-counter products aren't effective";
      case "Natural Remedies for Skin Health":
        return "• If skin condition worsens with natural treatments\n• If allergic reaction occurs (rash, swelling)\n• If needing diagnosis before trying remedies\n• For serious skin conditions requiring medical care\n• If natural remedy interacts with medications\n• If no improvement after reasonable trial period";
      default:
        return "• If symptoms persist or worsen despite self-care\n• If condition affects daily activities or sleep\n• If you develop signs of infection\n• If over-the-counter treatments don't help\n• If you have concerns about skin changes\n• For personalized treatment recommendations\n• If condition impacts mental health or self-esteem";
    }
  }
}
