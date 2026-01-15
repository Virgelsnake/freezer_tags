# NFC Manual Test Checklist

**Purpose:** Validate NFC read/write operations on physical iPhone device  
**Prerequisites:** Physical iPhone with NFC capability, NDEF-formatted NFC tags  
**Test Date:** _____________  
**Tester:** _____________  
**Device Model:** _____________  
**iOS Version:** _____________

---

## Test Scenarios

### 1. Write to Blank NDEF Tag

| Test Case | Expected Result | Actual Result | Pass/Fail | Notes |
|-----------|----------------|---------------|-----------|-------|
| Open app and tap "Add Container" | Form displays | | | |
| Fill in food name: "Chicken Soup" | Input accepted | | | |
| Select date frozen: Today | Date selected | | | |
| Add notes: "Contains vegetables" | Notes accepted (≤200 chars) | | | |
| Tap "Save & Scan Tag" | NFC session starts | | | |
| Hold iPhone near blank NDEF tag | Success message appears | | | |
| Verify data written | Tag contains container data | | | |

**Success Criteria:** Container data successfully written to tag, success confirmation displayed

---

### 2. Read from Written Tag

| Test Case | Expected Result | Actual Result | Pass/Fail | Notes |
|-----------|----------------|---------------|-----------|-------|
| Open app and tap "Scan Container" | NFC session starts | | | |
| Hold iPhone near previously written tag | Tag detected | | | |
| Wait for read completion | Container details display | | | |
| Verify food name matches | "Chicken Soup" displayed | | | |
| Verify date frozen matches | Correct date displayed | | | |
| Verify notes match | "Contains vegetables" displayed | | | |

**Success Criteria:** All container data read correctly and displayed

---

### 3. Write to Tag Already Containing Data

| Test Case | Expected Result | Actual Result | Pass/Fail | Notes |
|-----------|----------------|---------------|-----------|-------|
| Use tag from Test #1 | Tag has existing data | | | |
| Create new container with different data | Form filled | | | |
| Attempt to write to same tag | Write operation proceeds | | | |
| Verify new data overwrites old | New data on tag | | | |
| Scan tag to confirm | New container data displays | | | |

**Success Criteria:** New data successfully overwrites old data

---

### 4. Handle Tag Removed During Read

| Test Case | Expected Result | Actual Result | Pass/Fail | Notes |
|-----------|----------------|---------------|-----------|-------|
| Start scan operation | NFC session active | | | |
| Hold iPhone near tag briefly (< 1 sec) | Tag detected | | | |
| Remove tag before read completes | Error message displays | | | |
| Verify error message clarity | "Tag removed too quickly" shown | | | |
| Verify retry option available | Retry button present | | | |
| Tap retry and complete scan | Read succeeds on retry | | | |

**Success Criteria:** Clear error message, retry option works

---

### 5. Handle Tag Removed During Write

| Test Case | Expected Result | Actual Result | Pass/Fail | Notes |
|-----------|----------------|---------------|-----------|-------|
| Start write operation | NFC session active | | | |
| Hold iPhone near tag briefly (< 1 sec) | Tag detected | | | |
| Remove tag before write completes | Error message displays | | | |
| Verify error message clarity | "Tag removed too quickly" shown | | | |
| Check tag state | Tag not corrupted | | | |
| Retry write operation | Write succeeds on retry | | | |

**Success Criteria:** Error handled gracefully, tag remains usable, retry succeeds

---

### 6. Handle Multiple Tags in Range

| Test Case | Expected Result | Actual Result | Pass/Fail | Notes |
|-----------|----------------|---------------|-----------|-------|
| Place 2+ NFC tags close together | Tags in proximity | | | |
| Start scan operation | NFC session active | | | |
| Hold iPhone near multiple tags | Multiple tags detected | | | |
| Verify error message | "Multiple tags detected" shown | | | |
| Remove extra tags | Only one tag remains | | | |
| Retry scan | Scan succeeds with single tag | | | |

**Success Criteria:** Multiple tag scenario detected and handled with clear guidance

---

### 7. Handle Non-NDEF Tag

| Test Case | Expected Result | Actual Result | Pass/Fail | Notes |
|-----------|----------------|---------------|-----------|-------|
| Use non-NDEF formatted tag | Tag not compatible | | | |
| Attempt to scan | Tag detected | | | |
| Verify error message | "Not NDEF formatted" shown | | | |
| Verify guidance provided | Suggests NTAG213/215 | | | |

**Success Criteria:** Non-NDEF tags identified with helpful error message

---

### 8. Handle Unregistered Tag

| Test Case | Expected Result | Actual Result | Pass/Fail | Notes |
|-----------|----------------|---------------|-----------|-------|
| Use blank or non-app tag | Tag has no container data | | | |
| Attempt to scan | Tag read | | | |
| Verify message | "Unregistered tag" or similar | | | |
| Check for registration option | Option to write new data | | | |

**Success Criteria:** Unregistered tags handled appropriately

---

### 9. Handle Read-Only Tag (if available)

| Test Case | Expected Result | Actual Result | Pass/Fail | Notes |
|-----------|----------------|---------------|-----------|-------|
| Use read-only/locked NFC tag | Tag is read-only | | | |
| Attempt to write data | Write operation starts | | | |
| Verify error detection | "Read-only tag" error shown | | | |
| Verify tag not damaged | Tag still readable | | | |

**Success Criteria:** Read-only tags detected, clear error message shown

**Note:** Skip this test if read-only tag unavailable

---

## Performance Metrics

| Metric | Target | Actual | Notes |
|--------|--------|--------|-------|
| Average read time | < 2 seconds | | |
| Average write time | < 3 seconds | | |
| Read success rate | > 95% | | |
| Write success rate | > 95% | | |
| Error recovery success | 100% | | |

---

## Tag Compatibility Testing

| Tag Type | Model/Brand | Capacity | Read Success | Write Success | Notes |
|----------|-------------|----------|--------------|---------------|-------|
| NTAG213 | | 144 bytes | | | |
| NTAG215 | | 504 bytes | | | |
| NTAG216 | | 888 bytes | | | |
| Other | | | | | |

---

## Issues Encountered

| Issue # | Description | Severity | Workaround | Resolution |
|---------|-------------|----------|------------|------------|
| | | | | |
| | | | | |
| | | | | |

**Severity Levels:** Critical, High, Medium, Low

---

## Test Summary

**Total Tests Executed:** _____  
**Tests Passed:** _____  
**Tests Failed:** _____  
**Pass Rate:** _____%

**Overall Assessment:**
- [ ] All critical paths working
- [ ] Error handling adequate
- [ ] User experience acceptable
- [ ] Ready for demo

**Tester Signature:** _________________ **Date:** _____________

**Recommendations for Production:**
