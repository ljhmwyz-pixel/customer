package com.snyder.customer

import org.junit.Assert.assertEquals
import org.junit.Test

class AttachmentPickerTest {
    @Test
    fun `successful result with uri is selected`() {
        assertEquals(
            AttachmentPickerOutcome.SELECTED,
            attachmentPickerOutcome(resultCode = -1, hasUri = true)
        )
    }

    @Test
    fun `cancelled result is cancelled`() {
        assertEquals(
            AttachmentPickerOutcome.CANCELLED,
            attachmentPickerOutcome(resultCode = 0, hasUri = false)
        )
    }

    @Test
    fun `successful result without uri is invalid`() {
        assertEquals(
            AttachmentPickerOutcome.INVALID,
            attachmentPickerOutcome(resultCode = -1, hasUri = false)
        )
    }

    @Test
    fun `unknown result code is invalid`() {
        assertEquals(
            AttachmentPickerOutcome.INVALID,
            attachmentPickerOutcome(resultCode = 42, hasUri = true)
        )
    }
}
