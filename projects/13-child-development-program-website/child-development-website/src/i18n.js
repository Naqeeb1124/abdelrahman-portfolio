import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';

const resources = {
  en: {
    translation: {
      // Navigation
      "nav.home": "Home",
      "nav.programs": "Programs",
      "nav.about": "About Us",
      "nav.contact": "Contact",
      "nav.book": "Book Now",
      
      // Hero Section
      "hero.title": "Unlock Your Child's",
      "hero.subtitle": "Full Potential",
      "hero.description": "Comprehensive development programs that teach practical life skills and cognitive abilities for children aged 5-16 in Egypt.",
      "hero.cta": "Book Your Child's First Session",
      "hero.demo": "Watch Demo",
      "hero.families": "Happy Families",
      "hero.success": "Success Rate",
      "hero.experience": "Years Experience",
      
      // About Section
      "about.title": "About Our Program",
      "about.description": "We believe every child has unique potential waiting to be unlocked. Our comprehensive development programs go beyond traditional education to build essential life skills.",
      "about.mission.title": "Our Mission",
      "about.mission.description": "To empower children with the practical life skills and cognitive abilities they need to thrive in an ever-changing world. We focus on developing critical thinking, emotional intelligence, and social competence.",
      "about.mission.target": "Our programs are specifically designed for middle to upper-class families in Egypt who seek long-term value beyond the traditional school system.",
      "about.vision.title": "Our Vision",
      "about.vision.description": "To be Egypt's leading child development program, creating confident, capable, and compassionate future leaders.",
      
      // Programs
      "programs.title": "Our Development Programs",
      "programs.subtitle": "Age-appropriate curricula designed to unlock your child's potential at every stage of development",
      "programs.all": "All Programs",
      "programs.ages57": "Ages 5-7",
      "programs.ages810": "Ages 8-10",
      "programs.ages1113": "Ages 11-13",
      "programs.ages1416": "Ages 14-16",
      "programs.enroll": "Enroll Now",
      "programs.skills": "Key Skills Developed",
      "programs.activities": "Sample Activities",
      
      // Foundation Builders (5-7)
      "foundation.title": "Foundation Builders",
      "foundation.description": "Building basic life skills and emotional awareness through play-based learning and interactive activities.",
      "foundation.schedule": "Twice weekly - Tuesday & Thursday",
      "foundation.duration": "45 minutes",
      "foundation.size": "6-8 children",
      "foundation.price": "From 800 EGP/month",
      
      // Contact
      "contact.title": "Contact Us",
      "contact.subtitle": "We're here to answer your questions and help you get started on your child's development journey.",
      "contact.phone": "Phone",
      "contact.email": "Email",
      "contact.location": "Location",
      "contact.hours": "Hours",
      "contact.form.title": "Send Us a Message",
      "contact.form.name": "Full Name",
      "contact.form.email": "Email Address",
      "contact.form.phone": "Phone Number",
      "contact.form.subject": "Subject",
      "contact.form.message": "Message",
      "contact.form.send": "Send Message",
      
      // Footer
      "footer.description": "Empowering children with essential life skills and cognitive abilities for a successful future.",
      "footer.quicklinks": "Quick Links",
      "footer.contact": "Contact Info",
      "footer.follow": "Follow Us",
      "footer.rights": "All rights reserved."
    }
  },
  ar: {
    translation: {
      // Navigation
      "nav.home": "الرئيسية",
      "nav.programs": "البرامج",
      "nav.about": "من نحن",
      "nav.contact": "اتصل بنا",
      "nav.book": "احجز الآن",
      
      // Hero Section
      "hero.title": "اطلق إمكانات طفلك",
      "hero.subtitle": "الكاملة",
      "hero.description": "برامج تطوير شاملة تعلم المهارات الحياتية العملية والقدرات المعرفية للأطفال من سن 5-16 في مصر.",
      "hero.cta": "احجز الجلسة الأولى لطفلك",
      "hero.demo": "شاهد العرض التوضيحي",
      "hero.families": "عائلة سعيدة",
      "hero.success": "معدل النجاح",
      "hero.experience": "سنوات من الخبرة",
      
      // About Section
      "about.title": "حول برنامجنا",
      "about.description": "نؤمن أن كل طفل لديه إمكانات فريدة تنتظر الإطلاق. برامج التطوير الشاملة لدينا تتجاوز التعليم التقليدي لبناء المهارات الحياتية الأساسية.",
      "about.mission.title": "مهمتنا",
      "about.mission.description": "تمكين الأطفال بالمهارات الحياتية العملية والقدرات المعرفية التي يحتاجونها للازدهار في عالم متغير. نركز على تطوير التفكير النقدي والذكاء العاطفي والكفاءة الاجتماعية.",
      "about.mission.target": "برامجنا مصممة خصيصاً للعائلات من الطبقة المتوسطة والعليا في مصر الذين يسعون للقيمة طويلة المدى خارج النظام المدرسي التقليدي.",
      "about.vision.title": "رؤيتنا",
      "about.vision.description": "أن نكون برنامج تطوير الأطفال الرائد في مصر، وخلق قادة مستقبليين واثقين وقادرين ومتعاطفين.",
      
      // Programs
      "programs.title": "برامج التطوير لدينا",
      "programs.subtitle": "مناهج مناسبة للعمر مصممة لإطلاق إمكانات طفلك في كل مرحلة من مراحل التطوير",
      "programs.all": "جميع البرامج",
      "programs.ages57": "الأعمار 5-7",
      "programs.ages810": "الأعمار 8-10",
      "programs.ages1113": "الأعمار 11-13",
      "programs.ages1416": "الأعمار 14-16",
      "programs.enroll": "سجل الآن",
      "programs.skills": "المهارات الأساسية المطورة",
      "programs.activities": "أنشطة نموذجية",
      
      // Foundation Builders (5-7)
      "foundation.title": "بناة الأساس",
      "foundation.description": "بناء المهارات الحياتية الأساسية والوعي العاطفي من خلال التعلم القائم على اللعب والأنشطة التفاعلية.",
      "foundation.schedule": "مرتين أسبوعياً - الثلاثاء والخميس",
      "foundation.duration": "45 دقيقة",
      "foundation.size": "6-8 أطفال",
      "foundation.price": "من 800 جنيه مصري/شهر",
      
      // Contact
      "contact.title": "اتصل بنا",
      "contact.subtitle": "نحن هنا للإجابة على أسئلتك ومساعدتك في بدء رحلة تطوير طفلك.",
      "contact.phone": "الهاتف",
      "contact.email": "البريد الإلكتروني",
      "contact.location": "الموقع",
      "contact.hours": "ساعات العمل",
      "contact.form.title": "أرسل لنا رسالة",
      "contact.form.name": "الاسم الكامل",
      "contact.form.email": "عنوان البريد الإلكتروني",
      "contact.form.phone": "رقم الهاتف",
      "contact.form.subject": "الموضوع",
      "contact.form.message": "الرسالة",
      "contact.form.send": "إرسال الرسالة",
      
      // Footer
      "footer.description": "تمكين الأطفال بالمهارات الحياتية الأساسية والقدرات المعرفية لمستقبل ناجح.",
      "footer.quicklinks": "روابط سريعة",
      "footer.contact": "معلومات الاتصال",
      "footer.follow": "تابعنا",
      "footer.rights": "جميع الحقوق محفوظة."
    }
  }
};

i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources,
    fallbackLng: 'en',
    debug: false,
    
    interpolation: {
      escapeValue: false,
    },
    
    detection: {
      order: ['localStorage', 'navigator', 'htmlTag'],
      caches: ['localStorage'],
    }
  });

export default i18n;

