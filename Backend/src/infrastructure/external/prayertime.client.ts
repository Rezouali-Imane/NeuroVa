export interface PrayerTimes {
  Fajr: string;
  Dhuhr: string;
  Asr: string;
  Maghrib: string;
  Isha: string;
}

export const getPrayerTimes = async (
  city: string = 'Bejaia',
  country: string = 'Algeria'
): Promise<PrayerTimes> => {
  const res = await fetch(
    `https://api.aladhan.com/v1/timingsByCity?city=${city}&country=${country}&method=2`
  );
  const data = await res.json();
  const t = data.data.timings;
  return {
    Fajr: t.Fajr,
    Dhuhr: t.Dhuhr,
    Asr: t.Asr,
    Maghrib: t.Maghrib,
    Isha: t.Isha,
  };
};