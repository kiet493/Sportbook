const {initializeApp, applicationDefault} = require("firebase-admin/app");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");

initializeApp({credential: applicationDefault(), projectId: "sportbook-e74c7"});
const db = getFirestore();

const venues = [
  ["Cầu Giấy Badminton Center", "12 Trần Thái Tông, Cầu Giấy, Hà Nội", "21.0285,105.7896"],
  ["Tây Hồ Smash Arena", "88 Lạc Long Quân, Tây Hồ, Hà Nội", "21.0635,105.8180"],
  ["Thanh Xuân Sport Hub", "120 Nguyễn Trãi, Thanh Xuân, Hà Nội", "20.9977,105.8153"],
  ["Hà Đông Shuttle Club", "45 Quang Trung, Hà Đông, Hà Nội", "20.9714,105.7784"],
  ["Ba Đình Badminton House", "36 Kim Mã, Ba Đình, Hà Nội", "21.0341,105.8132"],
  ["Long Biên Court Arena", "25 Ngọc Lâm, Long Biên, Hà Nội", "21.0492,105.8811"],
  ["Hoàng Mai Sports Court", "210 Giải Phóng, Hoàng Mai, Hà Nội", "20.9814,105.8411"],
  ["Đống Đa Badminton Club", "75 Tây Sơn, Đống Đa, Hà Nội", "21.0126,105.8274"],
  ["Nam Từ Liêm Racket Park", "18 Mễ Trì, Nam Từ Liêm, Hà Nội", "21.0165,105.7817"],
  ["Hai Bà Trưng Shuttle Arena", "150 Bạch Mai, Hai Bà Trưng, Hà Nội", "21.0004,105.8509"],
];

async function seed() {
  const batch = db.batch();
  const ownerId = "seed_admin";
  for (let i = 0; i < venues.length; i++) {
    const [name, address, coordinates] = venues[i];
    const venueRef = db.collection("fieldComplexes").doc(`seed_hn_${String(i + 1).padStart(2, "0")}`);
    batch.set(venueRef, {
      _id: venueRef.id, id: venueRef.id, name, location: address, address, coordinates,
      sports: ["Cầu lông"], hours: "06:00 - 22:00", pricePerHour: 180000,
      isActive: true, active: true, ownerId, images: [], image: "", description: `Cụm sân cầu lông ${name}.`,
      rating: 0, reviews: 0, createdAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    for (let courtNo = 1; courtNo <= 4; courtNo++) {
      const courtRef = db.collection("sportFields").doc(`${venueRef.id}_court_${courtNo}`);
      batch.set(courtRef, {
        _id: courtRef.id, id: courtRef.id, complexId: venueRef.id, venueId: venueRef.id,
        name: `Sân ${courtNo}`, type: "Cầu lông", sport: "Cầu lông", location: address,
        capacity: 4, images: [], pricePerHour: 180000, amenities: ["Đèn", "Nước uống", "Bãi xe"],
        status: "active", active: true, sortOrder: courtNo,
        createdAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp(),
      }, {merge: true});
    }
  }
  await batch.commit();
  const [venueCheck, courtCheck] = await Promise.all([
    db.collection("fieldComplexes").where("ownerId", "==", ownerId).get(),
    db.collection("sportFields").where("id", ">=", "seed_hn_").where("id", "<", "seed_hn_\uf8ff").get(),
  ]);
  console.log(`Seed thành công: ${venueCheck.size} cụm sân, ${courtCheck.size} sân con.`);
}

seed().catch((error) => { console.error(error); process.exitCode = 1; });
