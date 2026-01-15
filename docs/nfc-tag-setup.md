# NFC Tag Setup Guide

## Overview

This guide covers NFC tag procurement, setup, and verification for the Freezer Tag Tracker prototype.

---

## Recommended Tag Types

### NTAG213 (Recommended for Prototype)

**Specifications:**
- Memory: 144 bytes user memory
- Compatibility: ISO14443A, NFC Forum Type 2
- Read/Write: Rewritable
- Typical Cost: $0.30-$0.50 per tag (bulk)

**Pros:**
- Sufficient capacity for container data
- Widely available
- Cost-effective
- Good compatibility with iPhone NFC

**Cons:**
- Limited capacity for future expansion

### NTAG215

**Specifications:**
- Memory: 504 bytes user memory
- Compatibility: ISO14443A, NFC Forum Type 2
- Read/Write: Rewritable
- Typical Cost: $0.40-$0.70 per tag (bulk)

**Pros:**
- Larger capacity for future features
- Same compatibility as NTAG213
- Still cost-effective

**Cons:**
- Slightly more expensive
- Overkill for current prototype needs

### NTAG216 (Optional)

**Specifications:**
- Memory: 888 bytes user memory
- Compatibility: ISO14443A, NFC Forum Type 2
- Read/Write: Rewritable
- Typical Cost: $0.50-$1.00 per tag (bulk)

**Pros:**
- Maximum capacity
- Future-proof

**Cons:**
- Higher cost
- Unnecessary for prototype

---

## Procurement Sources

### Amazon (Fast Shipping, Small Quantities)

**Search Terms:**
- "NTAG213 NFC tags"
- "NTAG215 NFC stickers"
- "NFC tags iPhone compatible"

**Recommended Quantity for Prototype:** 10-20 tags

**Estimated Cost:** $10-20 for 10-pack

**Typical Delivery:** 1-3 days (Prime)

### AliExpress (Bulk, Lower Cost)

**Search Terms:**
- "NTAG213 NFC tag"
- "ISO14443A NFC sticker"

**Recommended Quantity:** 50-100 tags (for extensive testing)

**Estimated Cost:** $15-30 for 50-pack

**Typical Delivery:** 2-4 weeks

### TagsForDroid / TagStand (Specialty NFC Retailers)

**Websites:**
- tagstand.com
- tagsfordroid.com

**Pros:**
- Guaranteed NDEF formatting
- Quality assurance
- Technical support

**Cons:**
- Higher cost per tag
- Slower shipping than Amazon

---

## Tag Form Factors

### Stickers (Recommended for Prototype)

**Description:** Adhesive-backed circular or rectangular tags

**Pros:**
- Easy to attach to containers
- Low profile
- Inexpensive

**Cons:**
- Adhesive may fail in freezer conditions
- Not reusable between containers

**Recommended Size:** 25mm diameter or 30mm x 50mm rectangle

### Hard Tags / Discs

**Description:** Rigid plastic encased tags

**Pros:**
- More durable
- Reusable
- Better for freezer environment

**Cons:**
- More expensive
- Requires attachment method (clip, magnet)

### Keychains / Fobs

**Description:** Tags in keychain form factor

**Pros:**
- Very durable
- Easy to handle
- Reusable

**Cons:**
- Bulky
- Not ideal for attaching to containers

---

## Verifying Tag Compatibility

### Using iPhone

**Method 1: NFC Tools App (Free)**

1. Download "NFC Tools" from App Store
2. Open app and tap "Read"
3. Hold iPhone near tag
4. Verify tag type shows as "NTAG213" or "NTAG215"
5. Check "Technologies" shows "Ndef"

**Method 2: Built-in NFC (iOS 14+)**

1. Ensure NFC is enabled in Settings
2. Hold iPhone near tag
3. If tag is blank, no notification appears (expected)
4. If tag has data, notification may appear

### Checking NDEF Format

**Using NFC Tools App:**

1. Tap "Read" in NFC Tools
2. Scan tag
3. Look for "NDEF" in tag info
4. If "NDEF" not present, tag needs formatting

**Formatting Tags:**

Most NTAG213/215 tags come pre-formatted as NDEF. If not:

1. Use NFC Tools app
2. Tap "Write"
3. Select "Erase tag"
4. Scan tag to erase
5. Tag is now NDEF-formatted

---

## Data Capacity Planning

### Current Prototype Data Structure

**ContainerRecord JSON (approximate size):**
```json
{
  "id": "UUID (36 chars)",
  "tagID": "string (20-50 chars)",
  "foodName": "string (up to 100 chars)",
  "dateFrozen": "ISO8601 date (25 chars)",
  "notes": "string (up to 200 chars)",
  "isCleared": "boolean (5 chars)",
  "createdAt": "ISO8601 date (25 chars)",
  "updatedAt": "ISO8601 date (25 chars)"
}
```

**Estimated Size:** 100-150 bytes (typical), up to 500 bytes (max with long notes)

**Conclusion:** NTAG213 (144 bytes) is sufficient for typical use, but may be tight with maximum-length notes. NTAG215 (504 bytes) provides comfortable headroom.

---

## Freezer Environment Considerations

### Temperature Resistance

**NFC Tag Specs:**
- Operating temperature: -25°C to 70°C (-13°F to 158°F)
- Typical home freezer: -18°C to -23°C (0°F to -10°F)

**Conclusion:** NTAG213/215 tags are rated for freezer use.

### Adhesive Performance

**Concern:** Standard adhesives may fail in freezer conditions

**Recommendations:**
1. Test adhesive performance in freezer before bulk purchase
2. Consider freezer-safe adhesive tags (available from specialty retailers)
3. Alternative: Use clip-on or magnetic tag holders

### Moisture/Condensation

**Concern:** Condensation when removing containers from freezer

**Recommendations:**
1. Use waterproof/sealed tags
2. Most NTAG stickers have protective coating
3. Test with condensation before deployment

---

## Tag Testing Protocol

Before using tags in prototype:

1. **Verify NDEF Format:** Use NFC Tools app to confirm
2. **Test Read/Write:** Write test data and read back
3. **Freezer Test:** Place tag in freezer for 24 hours, verify still readable
4. **Adhesion Test:** Attach to container, freeze, verify adhesive holds
5. **Rewrite Test:** Verify tag can be rewritten multiple times

---

## Cost Analysis for Production

### Per-Tag Cost at Scale

| Quantity | NTAG213 Cost/Tag | NTAG215 Cost/Tag |
|----------|------------------|------------------|
| 100 | $0.40 | $0.60 |
| 1,000 | $0.25 | $0.40 |
| 10,000 | $0.15 | $0.25 |
| 100,000 | $0.10 | $0.18 |

**Note:** Prices are estimates and vary by supplier, form factor, and customization.

### Additional Costs

- Custom printing/branding: +$0.05-$0.20 per tag
- Packaging: +$0.02-$0.10 per tag
- Shipping: Varies by quantity and location

---

## Recommended Prototype Purchase

**For Initial Testing:**
- Quantity: 20 tags
- Type: NTAG213 stickers (25mm diameter)
- Source: Amazon
- Estimated Cost: $15-20
- Delivery: 1-3 days

**For Extensive Testing:**
- Quantity: 50 tags
- Type: Mix of NTAG213 and NTAG215
- Source: AliExpress or bulk supplier
- Estimated Cost: $20-30
- Delivery: 2-4 weeks

---

## Troubleshooting

### Tag Not Detected

**Possible Causes:**
- Tag not NDEF formatted
- Tag damaged
- iPhone NFC not enabled
- Tag too far from iPhone NFC antenna

**Solutions:**
- Verify NDEF format with NFC Tools app
- Try different tag
- Check iPhone Settings > NFC
- Hold iPhone back (near camera) to tag

### Write Fails

**Possible Causes:**
- Tag is read-only/locked
- Tag memory full
- Tag removed too quickly
- Data too large for tag capacity

**Solutions:**
- Verify tag is writable
- Use NTAG215 for larger capacity
- Hold iPhone steady for 2-3 seconds
- Reduce notes length

### Inconsistent Reads

**Possible Causes:**
- Poor tag quality
- Interference from metal surfaces
- Tag adhesive failing

**Solutions:**
- Purchase higher quality tags
- Avoid placing tags on metal lids
- Re-attach or replace tag

---

## Resources

**NFC Forum:** nfc-forum.org  
**NFC Tools App:** App Store (free)  
**NTAG Datasheet:** Available from NXP Semiconductors  
**iPhone NFC Compatibility:** iPhone 7 and newer
