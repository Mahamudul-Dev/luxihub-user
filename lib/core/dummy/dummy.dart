import '../domain/entities/category_entity.dart';
import '../domain/entities/review_entity.dart';
import '../domain/entities/service_provider_entity.dart';
import '../domain/entities/user_entity.dart';

class Dummy {
  Dummy._();

  // ── Reviews ───────────────────────────────────────────────────────────────

  static const List<ReviewEntity> reviews = [
    ReviewEntity(
      id: 'rev-001',
      reviewerName: 'Emily Watson',
      reviewerAvatarUrl: 'https://randomuser.me/api/portraits/women/62.jpg',
      rating: 5.0,
      comment: 'Absolutely fantastic work! Very professional and finished ahead of schedule.',
      date: 'March 2025',
    ),
    ReviewEntity(
      id: 'rev-002',
      reviewerName: 'Oliver Brooks',
      reviewerAvatarUrl: 'https://randomuser.me/api/portraits/men/75.jpg',
      rating: 4.0,
      comment: 'Great quality and easy to communicate with. Would definitely hire again.',
      date: 'February 2025',
    ),
    ReviewEntity(
      id: 'rev-003',
      reviewerName: 'Priya Sharma',
      reviewerAvatarUrl: 'https://randomuser.me/api/portraits/women/48.jpg',
      rating: 4.5,
      comment: 'Neat, tidy and very knowledgeable. Minor delay but overall excellent service.',
      date: 'January 2025',
    ),
    ReviewEntity(
      id: 'rev-004',
      reviewerName: 'Tom Clarke',
      reviewerAvatarUrl: 'https://randomuser.me/api/portraits/men/34.jpg',
      rating: 5.0,
      comment: 'Best handyman I have used. Fixed the issue quickly and at a fair price.',
      date: 'December 2024',
    ),
  ];

  // ── Categories ────────────────────────────────────────────────────────────

  static const List<CategoryEntity> categories = [
    CategoryEntity(id: 'cat-001', name: 'Plumbing',            imageUrl: 'assets/images/plumber.png',   serviceCount: 42),
    CategoryEntity(id: 'cat-002', name: 'Painting',            imageUrl: 'assets/images/painter.png',   serviceCount: 35),
    CategoryEntity(id: 'cat-003', name: 'Carpentry',           imageUrl: 'assets/images/carpenter.png', serviceCount: 28),
    CategoryEntity(id: 'cat-004', name: 'Electrical',          imageUrl: 'https://cdn-icons-png.flaticon.com/512/3274/3274217.png', serviceCount: 31),
    CategoryEntity(id: 'cat-005', name: 'Cleaning',            imageUrl: 'https://cdn-icons-png.flaticon.com/512/995/995016.png',   serviceCount: 54),
    CategoryEntity(id: 'cat-006', name: 'Landscaping',         imageUrl: 'https://cdn-icons-png.flaticon.com/512/2942/2942909.png', serviceCount: 19),
    CategoryEntity(id: 'cat-007', name: 'HVAC',                imageUrl: 'https://cdn-icons-png.flaticon.com/512/4248/4248480.png', serviceCount: 22),
    CategoryEntity(id: 'cat-008', name: 'General Maintenance', imageUrl: 'https://cdn-icons-png.flaticon.com/512/1995/1995574.png', serviceCount: 47),
  ];

  // ── Users ──────────────────────────────────────────────────────────────────

  static const List<UserEntity> users = [_u1, _u2, _u3, _u4, _u5];

  static const _u1 = UserEntity(
    id: 'user-001',
    firstName: 'James',
    lastName: 'Carter',
    email: 'james.carter@example.com',
    phone: '+44 7700 900001',
    address: '12 Baker Street',
    city: 'London',
    country: 'United Kingdom',
    profileImageUrl: 'https://randomuser.me/api/portraits/men/11.jpg',
    bio: 'Experienced plumber with over 10 years in residential and commercial projects.',
    tocAccepted: true,
  );

  static const _u2 = UserEntity(
    id: 'user-002',
    firstName: 'Sophia',
    lastName: 'Mitchell',
    email: 'sophia.mitchell@example.com',
    phone: '+44 7700 900002',
    address: '34 Elm Avenue',
    city: 'Manchester',
    country: 'United Kingdom',
    profileImageUrl: 'https://randomuser.me/api/portraits/women/21.jpg',
    bio: 'Professional painter specialising in interior design and decorative finishes.',
    tocAccepted: true,
  );

  static const _u3 = UserEntity(
    id: 'user-003',
    firstName: 'Daniel',
    lastName: 'Brooks',
    email: 'daniel.brooks@example.com',
    phone: '+44 7700 900003',
    address: '7 Oak Lane',
    city: 'Birmingham',
    country: 'United Kingdom',
    profileImageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    bio: 'Master carpenter crafting custom furniture and bespoke woodwork since 2008.',
    tocAccepted: true,
  );

  static const _u4 = UserEntity(
    id: 'user-004',
    firstName: 'Aisha',
    lastName: 'Rahman',
    email: 'aisha.rahman@example.com',
    phone: '+44 7700 900004',
    address: '88 Maple Road',
    city: 'Leeds',
    country: 'United Kingdom',
    profileImageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    bio: 'Certified electrician handling everything from wiring to smart-home installations.',
    tocAccepted: true,
  );

  static const _u5 = UserEntity(
    id: 'user-005',
    firstName: 'Luca',
    lastName: 'Ferrari',
    email: 'luca.ferrari@example.com',
    phone: '+44 7700 900005',
    address: '21 Pine Close',
    city: 'Bristol',
    country: 'United Kingdom',
    profileImageUrl: 'https://randomuser.me/api/portraits/men/55.jpg',
    bio: 'Versatile handyman covering plumbing repairs, tiling, and general maintenance.',
    tocAccepted: true,
  );

  // ── Service Providers ──────────────────────────────────────────────────────

  static const List<ServiceProviderEntity> providers = [
    _p1, _p2, _p3, _p4, _p5,
  ];

  static const _p1 = ServiceProviderEntity(
    user: _u1,
    category: 'Plumbing',
    skills: ['Pipe fitting', 'Leak repair', 'Boiler servicing', 'Drain unblocking'],
    ratePerHour: 35,
    currency: '£',
    yearsOfExperience: 10,
    isAvailable: true,
    rating: 4.8,
    reviewCount: 312,
    completedJobs: 408,
  );

  static const _p2 = ServiceProviderEntity(
    user: _u2,
    category: 'Painting',
    skills: ['Interior painting', 'Wallpapering', 'Decorative finishes', 'Colour consulting'],
    ratePerHour: 28,
    currency: '£',
    yearsOfExperience: 7,
    isAvailable: true,
    rating: 4.6,
    reviewCount: 185,
    completedJobs: 230,
  );

  static const _p3 = ServiceProviderEntity(
    user: _u3,
    category: 'Carpentry',
    skills: ['Custom furniture', 'Door fitting', 'Flooring', 'Cabinet making'],
    ratePerHour: 40,
    currency: '£',
    yearsOfExperience: 15,
    isAvailable: false,
    rating: 4.9,
    reviewCount: 420,
    completedJobs: 510,
  );

  static const _p4 = ServiceProviderEntity(
    user: _u4,
    category: 'Electrical',
    skills: ['Wiring', 'Fuse board upgrades', 'Smart home setup', 'Safety testing'],
    ratePerHour: 45,
    currency: '£',
    yearsOfExperience: 9,
    isAvailable: true,
    rating: 4.7,
    reviewCount: 278,
    completedJobs: 340,
  );

  static const _p5 = ServiceProviderEntity(
    user: _u5,
    category: 'General Maintenance',
    skills: ['Tiling', 'Plastering', 'Flat-pack assembly', 'Minor plumbing'],
    ratePerHour: 25,
    currency: '£',
    yearsOfExperience: 6,
    isAvailable: true,
    rating: 4.4,
    reviewCount: 134,
    completedJobs: 175,
  );
}
