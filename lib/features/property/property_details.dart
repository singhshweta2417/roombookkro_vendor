import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/core/constants/app_fonts.dart';
import 'package:room_book_kro_vendor/core/routes/app_routes.dart';
import 'package:room_book_kro_vendor/core/theme/app_colors.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_container.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
import 'package:room_book_kro_vendor/core/widgets/primary_button.dart';
import 'package:room_book_kro_vendor/features/property/property_model.dart';
import '../../core/widgets/app_text.dart';
import '../../core/widgets/slider_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyDetailsScreen extends ConsumerStatefulWidget {
  const PropertyDetailsScreen({super.key});

  @override
  ConsumerState<PropertyDetailsScreen> createState() =>
      _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends ConsumerState<PropertyDetailsScreen> {
  AddPropertyListData? propertyData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ Receive arguments
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is AddPropertyListData) {
      setState(() {
        propertyData = args;
      });
    } else {
      // ✅ Handle error if no data received
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: AppText(text: 'Property data not found')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (propertyData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return CustomScaffold(
      padding: EdgeInsets.zero,
      bottomNavigationBar: _buildBottomBar(),
      child: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildPropertyInfo(),
          _buildAmenitiesSection(),
          _buildRoomsSection(),
          _buildRulesSection(),
          _buildContactSection(),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: context.sh * 0.25,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.secondary(ref),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppColors.text(ref)),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: AppText(
          text: propertyData?.name?.toString() ?? 'Property Details',
          color: AppColors.text(ref),
          fontType: FontType.bold,
        ),
        background: TCustomContainer(
          child: SliderWidget(
            showDots: false,
            imgUrls: propertyData?.images ?? [],
            height: context.sh * 0.3,
            borderRadius: BorderRadius.circular(0),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildPropertyInfo() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildRatingBadge(),
                const SizedBox(width: 8),
                AppText(
                  text: '${propertyData?.availableRooms ?? 0} Rooms Available',
                  color: Colors.green,
                  fontType: FontType.bold,
                ),
              ],
            ),
            const SizedBox(height: 8),
            AppText(
              text: propertyData?.name?.toString() ?? '',
              fontSize: context.sh * 0.03,
              fontType: FontType.bold,
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: AppText(
                    text:
                        '${propertyData?.address ?? ''}, ${propertyData?.city ?? ''}, ${propertyData?.state ?? ''} - ${propertyData?.pincode ?? ''}',
                    color: Colors.grey[600],
                    fontSize: context.sh * 0.015,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppText(
              text: 'Description',
              fontSize: context.sh * 0.02,
              fontType: FontType.bold,
            ),
            const SizedBox(height: 4),
            AppText(
              text:
                  propertyData?.description?.toString() ??
                  'No description available',
              fontSize: 16,
            ),
            const SizedBox(height: 16),
            _buildPriceSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBadge() {
    final rating = propertyData?.rating ?? 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.orange, size: 16),
          const SizedBox(width: 4),
          AppText(
            text: rating.toString(),
            color: Colors.orange[800],
            fontType: FontType.medium,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    final pricePerDay = propertyData?.pricePerDay ?? 0;
    final pricePerMonth = propertyData?.pricePerMonth ?? 0;
    final pricePerNight = propertyData?.pricePerNight ?? 0;
    final discountValue =
        int.tryParse(propertyData?.discount?.toString() ?? '0') ?? 0;

    final isHotel = propertyData?.propertyTypeId?.toString() == '1';

    return TCustomContainer(
      padding: const EdgeInsets.all(16),
      lightColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: 'Starting from',
                color: Colors.grey[600],
                fontSize: 12,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  AppText(
                    text: isHotel
                        ? '₹$pricePerNight'
                        : propertyData?.propertyTypeId.toString() == "3" ||
                              propertyData?.propertyTypeId.toString() == "4"
                        ? ""
                        : '₹$pricePerDay',
                    fontSize: 24,
                    fontType: FontType.bold,
                    color: AppColors.secondary(ref),
                  ),
                  const SizedBox(width: 8),
                  AppText(
                    text: isHotel
                        ? '/night'
                        : propertyData?.propertyTypeId.toString() == "3" ||
                              propertyData?.propertyTypeId.toString() == "4"
                        ? ""
                        : '/day',
                    color: Colors.grey[600],
                  ),
                ],
              ),
              if (!isHotel) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    AppText(
                      text: '₹$pricePerMonth',
                      color: AppColors.secondary(ref),
                    ),
                    AppText(text: '/month', color: AppColors.text(ref)),
                  ],
                ),
              ],
            ],
          ),
          if (discountValue > 0)
            TCustomContainer(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              lightColor: Colors.red[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red),
              child: AppText(
                text: '$discountValue% OFF',
                color: Colors.red,
                fontType: FontType.bold,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildAmenitiesSection() {
    final amenities = propertyData?.amenities ?? [];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              text: 'Facilities',
              fontSize: 20,
              fontType: FontType.bold,
            ),
            SizedBox(height: context.sh * 0.015),
            amenities.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: AppText(
                        text: 'No facilities available',
                        fontType: FontType.medium,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: amenities.length,
                    itemBuilder: (context, index) {
                      final amenity = amenities[index];
                      return Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.secondary(ref),
                              ),
                            ),
                            child: ImageIcon(
                              NetworkImage(amenity.icon?.toString() ?? ''),
                              color: AppColors.secondary(ref),
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AppText(
                            text: amenity.name?.toString() ?? '',
                            textAlign: TextAlign.center,
                            fontSize: 12,
                            fontType: FontType.semiBold,
                            maxLines: 2,
                          ),
                        ],
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildRoomsSection() {
    final rooms = propertyData?.rooms ?? [];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              text: 'Available Rooms',
              fontSize: 20,
              fontType: FontType.bold,
            ),
            const SizedBox(height: 12),
            rooms.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: AppText(text: 'No rooms available'),
                    ),
                  )
                : Column(
                    children: rooms
                        .map((room) => _buildRoomCard(room))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(Rooms room) {
    final propertyType = propertyData?.propertyTypeId ?? [];
    final roomImages = room.images ?? [];
    final roomAmenities = room.amenities ?? [];
    final isAvailable = room.isAvailable ?? false;
    return TCustomContainer(
      margin: const EdgeInsets.only(bottom: 12),
      lightColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      child: Column(
        children: [
          TCustomContainer(
            height: 120,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            backgroundImage: DecorationImage(
              image: NetworkImage(
                roomImages.isNotEmpty
                    ? roomImages.first
                    : 'https://via.placeholder.com/400x200',
              ),
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.sw * 0.015,
              vertical: context.sh * 0.015,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppText(
                        text:
                            '${room.roomType ?? ''} - ${room.furnished ?? ''}',
                        fontSize: 18,
                        fontType: FontType.bold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TCustomContainer(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      lightColor: isAvailable
                          ? Colors.green[50]
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isAvailable ? Colors.green : Colors.red,
                      ),
                      child: AppText(
                        text: isAvailable
                            ? '${room.availableUnits ?? 0} Available'
                            : 'Not Available',
                        color: isAvailable ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontType: FontType.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    AppText(text: 'Up to ${room.occupancy ?? 0} people'),
                    const SizedBox(width: 16),
                    const Icon(Icons.image, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    AppText(text: '${roomImages.length} photos'),
                  ],
                ),
                const SizedBox(height: 8),
                if (roomAmenities.isNotEmpty)
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: roomAmenities.map((amenity) {
                      return SizedBox(
                        width: context.sw * 0.25,
                        child: Chip(
                          labelPadding: EdgeInsets.zero,
                          label: Row(
                            children: [
                              ImageIcon(
                                CachedNetworkImageProvider(
                                  amenity.icon.toString(),
                                ),
                                size: 20,
                                color: Colors.black,
                              ),
                              SizedBox(width: context.sw * 0.01),
                              AppText(
                                text: amenity.name?.toString() ?? '',
                                fontSize: context.sh * 0.015,
                                fontType: FontType.semiBold,
                              ),
                            ],
                          ),
                          backgroundColor: AppColors.secondary(ref),
                          visualDensity: VisualDensity.compact,
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 12),
                propertyType.toString() == "1"
                    ? Row(
                        children: [
                          AppText(
                            text: '₹${room.price ?? 0}',
                            fontType: FontType.bold,
                            color: AppColors.secondary(ref),
                          ),
                          AppText(
                            text: ' /night',
                            color: AppColors.text(ref),
                            fontType: FontType.bold,
                            fontSize: context.sh * 0.015,
                          ),
                        ],
                      )
                    : propertyType.toString() == "3" || propertyType.toString() == "4"
                    ? Row(
                        children: [
                          AppText(
                            text: '₹${room.price ?? 0}',
                            fontType: FontType.bold,
                            color: AppColors.secondary(ref),
                          ),
                          AppText(
                            text: ' /month',
                            color: AppColors.text(ref),
                            fontType: FontType.bold,
                            fontSize: context.sh * 0.015,
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              AppText(
                                text: '₹${room.roomPricePerDay ?? 0}',
                                fontSize: 18,
                                fontType: FontType.bold,
                                color: AppColors.secondary(ref),
                              ),
                              AppText(
                                text: ' /day',
                                fontSize: context.sh * 0.015,
                                fontType: FontType.bold,
                                color: AppColors.text(ref),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              AppText(
                                text: '₹${room.price ?? 0}',
                                fontType: FontType.bold,
                                color: AppColors.secondary(ref),
                              ),
                              AppText(
                                text: ' /month',
                                color: AppColors.text(ref),
                                fontType: FontType.bold,
                                fontSize: context.sh * 0.015,
                              ),
                            ],
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildRulesSection() {
    final rules = propertyData?.rules ?? [];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(text: 'House Rules', fontSize: 20, fontType: FontType.bold),
            const SizedBox(height: 12),
            rules.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: AppText(
                        text: 'No rules specified',
                        color: AppColors.text(ref),
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.background(ref),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: rules.map((rule) {
                        return Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppText(
                                text: rule.toString(),
                                fontSize: context.sh * 0.02,
                                fontType: FontType.bold,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildContactSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: 'Contact Information',
              fontSize: 20,
              fontType: FontType.bold,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildContactItem(
                    Icons.person,
                    'Owner',
                    propertyData?.owner?.toString() ?? 'N/A',
                  ),
                  _buildContactItem(
                    Icons.work,
                    'Role',
                    propertyData?.role?.toString() ?? 'N/A',
                  ),
                  _buildContactItem(
                    Icons.phone,
                    'Contact',
                    propertyData?.contactNumber?.toString() ?? 'N/A',
                  ),
                  _buildContactItem(
                    Icons.email,
                    'Email',
                    propertyData?.email?.toString() ?? 'N/A',
                  ),
                  if (propertyData?.website != null)
                    _buildContactItem(
                      Icons.language,
                      'Website',
                      propertyData?.website?.toString() ?? 'N/A',
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.secondary(ref)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(text: title, fontSize: 12, color: Colors.grey[600]),
              const SizedBox(height: 2),
              AppText(text: value, fontSize: 14, fontType: FontType.medium),
            ],
          ),
          const Spacer(),
          if (title == 'Contact' || title == 'Website')
            IconButton(
              icon: Icon(
                title == 'Contact' ? Icons.phone : Icons.open_in_new,
                color: AppColors.secondary(ref),
              ),
              onPressed: () => makePhoneCall(value),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final pricePerDay = propertyData?.pricePerMonth ?? 0;
    final pricePerNight = propertyData?.pricePerNight ?? 0;
    final type = propertyData?.propertyTypeId ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  text: 'Starting from',
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                Row(
                  children: [
                    AppText(
                      text:
                          '₹${type.toString() == "1" ? pricePerNight.toStringAsFixed(2) : pricePerDay.toStringAsFixed(2)}',
                      fontSize: context.sh * 0.02,
                      fontType: FontType.bold,
                      color: AppColors.secondary(ref),
                    ),
                    AppText(
                      text: type.toString() == "1" ? '/night' : "/month",
                      fontSize: context.sh * 0.015,
                      fontType: FontType.bold,
                      color: AppColors.secondary(ref),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PrimaryButton(
            width: context.sw * 0.5,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.editPropertyScreen1,
                arguments: propertyData,
              );
            },
            label: "Edit Property",
          ),
        ],
      ),
    );
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    }
  }
}
