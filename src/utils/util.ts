/**
 * @method isEmpty
 * @param {String | Number | Object} value
 * @returns {Boolean} true & false
 * @description this value is Empty Check
 */
export const isEmpty = (value: string | number | object): boolean => {
  if (value === null) {
    return true;
  } else if (typeof value !== 'number' && value === '') {
    return true;
  } else if (typeof value === 'undefined' || value === undefined) {
    return true;
  } else if (value !== null && typeof value === 'object' && !Object.keys(value).length) {
    return true;
  } else {
    return false;
  }
};

/**
 * @method parseOrigins
 * @param {String} origin
 * @returns {Boolean | String[]}
 * @description parses comma-separated origins into an array, returns true for wildcard '*'
 */
export const parseOrigins = (origin: string): boolean | string[] => {
  if (origin.trim() === '*') {
    return true;
  }
  return origin
    .split(',')
    .map(o => o.trim())
    .filter(Boolean);
};
