import 'dart:math';
import 'dart:core';

// Default geohash length
const g_GEOHASH_PRECISION = 10;

// Characters used in location geohashes
const g_BASE32 = '0123456789bcdefghjkmnpqrstuvwxyz';

// The meridional circumference of the earth in meters
const g_EARTH_MERI_CIRCUMFERENCE = 40007860;

// Length of a degree latitude at the equator
const g_METERS_PER_DEGREE_LATITUDE = 110574;

// Number of bits per geohash character
const g_BITS_PER_CHAR = 5;

// Maximum length of a geohash in bits
const g_MAXIMUM_BITS_PRECISION = 22 * g_BITS_PER_CHAR;

// Equatorial radius of the earth in meters
const g_EARTH_EQ_RADIUS = 6378137.0;

// The following value assumes a polar radius of
// var g_EARTH_POL_RADIUS = 6356752.3;
// The formulate to calculate g_E2 is
// g_E2 == (g_EARTH_EQ_RADIUS^2-g_EARTH_POL_RADIUS^2)/(g_EARTH_EQ_RADIUS^2)
// The exact value is used here to avoid rounding errors
const g_E2 = 0.00669447819799;

// Cutoff for rounding errors on double calculations
const g_EPSILON = 1e-12;

double log2(double x) {
  return log(x) / log(2);
}

double degreesToRadians(double degrees) {
  return (degrees * pi / 180);
}

String encodeGeohash(List<double> location, int precision) {
  // Use the global precision default if no precision is specified
  precision = precision ?? g_GEOHASH_PRECISION;

  var latitudeRange = {'min': -90.0, 'max': 90.0};
  var longitudeRange = {'min': -180.0, 'max': 180.0};
  var hash = '';
  var hashVal = 0;
  var bits = 0;
  var even = true;

  while (hash.length < precision) {
    var val = even ? location[1] : location[0];
    var range = even ? longitudeRange : latitudeRange;
    var mid = (range['min'] + range['max']) / 2;

    /* jshint -W016 */
    if (val > mid) {
      hashVal = (hashVal << 1) + 1;
      range['min'] = mid;
    } else {
      hashVal = (hashVal << 1) + 0;
      range['max'] = mid;
    }
    /* jshint +W016 */

    even = !even;
    if (bits < 4) {
      bits++;
    } else {
      bits = 0;
      hash += g_BASE32[hashVal];
      hashVal = 0;
    }
  }

  return hash;
}

double metersToLongitudeDegrees(double distance, double latitude) {
  var radians = degreesToRadians(latitude);
  var num = cos(radians) * g_EARTH_EQ_RADIUS * pi / 180;
  var denom = 1 / sqrt(1 - g_E2 * sin(radians) * sin(radians));
  var deltaDeg = num * denom;
  if (deltaDeg < g_EPSILON) {
    return distance > 0 ? 360 : 0;
  } else {
    return min(360, distance / deltaDeg);
  }
}

double longitudeBitsForResolution(double resolution, double latitude) {
  var degs = metersToLongitudeDegrees(resolution, latitude);
  return (degs.abs() > 0.000001) ? max(1, log2(360 / degs)) : 1;
}

double latitudeBitsForResolution(double resolution) {
  return min(log2(g_EARTH_MERI_CIRCUMFERENCE / 2 / resolution),
      g_MAXIMUM_BITS_PRECISION.toDouble());
}

double wrapLongitude(double longitude) {
  if (longitude <= 180 && longitude >= -180) {
    return longitude;
  }
  var adjusted = longitude + 180;
  if (adjusted > 0) {
    return (adjusted % 360) - 180;
  } else {
    return 180 - (-adjusted % 360);
  }
}

int boundingBoxBits(List<double> coordinate, double size) {
  var latDeltaDegrees = size / g_METERS_PER_DEGREE_LATITUDE;
  var latitudeNorth = min(90, coordinate[0] + latDeltaDegrees);
  var latitudeSouth = max(-90, coordinate[0] - latDeltaDegrees);
  var bitsLat = (latitudeBitsForResolution(size)).floor() * 2;
  var bitsLongNorth =
      (longitudeBitsForResolution(size, latitudeNorth)).floor() * 2 - 1;
  var bitsLongSouth =
      (longitudeBitsForResolution(size, latitudeSouth)).floor() * 2 - 1;

  var array = [bitsLat, bitsLongNorth, bitsLongSouth, g_MAXIMUM_BITS_PRECISION];

  array.sort();

  return array.first;
}

List<List<double>> boundingBoxCoordinates(List<double> center, double radius) {
  var latDegrees = radius / g_METERS_PER_DEGREE_LATITUDE;
  var latitudeNorth = min(90, center[0] + latDegrees);
  var latitudeSouth = max(-90, center[0] - latDegrees);
  var longDegsNorth = metersToLongitudeDegrees(radius, latitudeNorth);
  var longDegsSouth = metersToLongitudeDegrees(radius, latitudeSouth);
  var longDegs = max(longDegsNorth, longDegsSouth);
  return [
    [center[0], center[1]],
    [center[0], wrapLongitude(center[1] - longDegs)],
    [center[0], wrapLongitude(center[1] + longDegs)],
    [latitudeNorth, center[1]],
    [latitudeNorth, wrapLongitude(center[1] - longDegs)],
    [latitudeNorth, wrapLongitude(center[1] + longDegs)],
    [latitudeSouth, center[1]],
    [latitudeSouth, wrapLongitude(center[1] - longDegs)],
    [latitudeSouth, wrapLongitude(center[1] + longDegs)]
  ];
}

List<String> geohashQuery(String geohash, int bits) {
  var precision = (bits / g_BITS_PER_CHAR).ceil();
  if (geohash.length < precision) {
    return [geohash, geohash + '~'];
  }
  geohash = geohash.substring(0, precision);
  var base = geohash.substring(0, geohash.length - 1);
  var lastValue = g_BASE32.indexOf(geohash[geohash.length - 1]);
  var significantBits = bits - (base.length * g_BITS_PER_CHAR);
  var unusedBits = (g_BITS_PER_CHAR - significantBits);
  /*jshint bitwise: false*/
  // delete unused bits
  var startValue = (lastValue >> unusedBits) << unusedBits;
  var endValue = startValue + (1 << unusedBits);
  /*jshint bitwise: true*/
  if (endValue >= g_BASE32.length) {
    return [base + g_BASE32[startValue], base + '~'];
  } else {
    return [base + g_BASE32[startValue], base + g_BASE32[endValue]];
  }
}

List<List<String>> geohashQueries(List<double> center, double radius) {
  var queryBits = max(1, boundingBoxBits(center, radius));
  var geohashPrecision = (queryBits / g_BITS_PER_CHAR).ceil();
  var coordinates = boundingBoxCoordinates(center, radius);
  var queries = coordinates.map((coordinate) {
    return geohashQuery(encodeGeohash(coordinate, geohashPrecision), queryBits);
  }).toList();

  // remove duplicates

  var newArray = <List<String>>[];

  for (var firstArray in queries) {
    var isFound = false;

    for (var currentList in newArray) {
      if (firstArray[0] == currentList[0] && firstArray[1] == currentList[1]) {
        isFound = true;
      }
    }

    if (!isFound) {
      newArray.add(firstArray);
    }
  }

  return newArray;

/*  

  return queries.where((query) {
    index++;
    return !queries.any((other) {
      otherIndex++;
      return index > otherIndex &&
          deepEq(query[0], other[0]) &&
          deepEq(query[1], other[1]);
    });
  }).toList();
 */
}

double distance(List<double> location1, List<double> location2) {
  var radius = 6371; // Earth's radius in kilometers
  var latDelta = degreesToRadians(location2[0] - location1[0]);
  var lonDelta = degreesToRadians(location2[1] - location1[1]);

  var a = (sin(latDelta / 2) * sin(latDelta / 2)) +
      (cos(degreesToRadians(location1[0])) *
          cos(degreesToRadians(location2[0])) *
          sin(lonDelta / 2) *
          sin(lonDelta / 2));

  var c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return radius * c;
}
