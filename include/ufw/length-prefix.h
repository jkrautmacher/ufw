/*
 * Copyright (c) 2022-2024 micro framework workers, All rights reserved.
 *
 * Terms for redistribution and use can be found in LICENCE.
 */

/**
 * @file length-prefix.h
 * @brief Length prefix framing implementation
 */

#ifndef INC_UFW_LENGTH_PREFIX_H
#define INC_UFW_LENGTH_PREFIX_H

#include <stddef.h>

#include <ufw/byte-buffer.h>
#include <ufw/endpoints.h>
#include <ufw/variable-length-integer.h>

typedef struct ufw_length_prefix_buffer {
    unsigned char prefix_[VARINT_64BIT_MAX_OCTETS];
    ByteBuffer prefix;
    ByteBuffer payload;
} LengthPrefixBuffer;

typedef struct ufw_length_prefix_chunks {
    unsigned char prefix_[VARINT_64BIT_MAX_OCTETS];
    ByteBuffer prefix;
    ByteChunks payload;
} LengthPrefixChunks;

int lenp_memory_encode(LengthPrefixBuffer*, void*, size_t);
int lenp_buffer_encode(LengthPrefixBuffer*, ByteBuffer*);
int lenp_buffer_encode_n(LengthPrefixBuffer*, ByteBuffer*, size_t);
int lenp_chunks_use(LengthPrefixChunks*);

ssize_t lenp_memory_to_sink(Sink*, void*, size_t);
ssize_t lenp_buffer_to_sink(Sink*, ByteBuffer*);
ssize_t lenp_buffer_to_sink_n(Sink*, ByteBuffer*, size_t);
ssize_t lenp_chunks_to_sink(Sink*, ByteChunks*);

ssize_t lenp_memory_from_source(Source*, void*, size_t);
ssize_t lenp_buffer_from_source(Source*, ByteBuffer*);

ssize_t lenp_decode_source_to_sink(Source*, Sink*);

#endif /* INC_UFW_LENGTH_PREFIX_H */
