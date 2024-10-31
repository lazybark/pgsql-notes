-- Home-made UUIDv7 generator

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION uuid_generate_v7() RETURNS UUID AS $$
DECLARE
    ts BIGINT;
    rand_part BYTEA;
BEGIN
    -- Current timestamp in milliseconds since epoch.
    ts := extract(epoch from clock_timestamp()) * 1000;

    -- Generate 10 random bytes (80 bits) for the remaining part.
    rand_part := gen_random_bytes(10);

    -- Construct the UUIDv7 (big-endian byte order).
    RETURN (
        lpad(to_hex(ts), 12, '0') || -- 48 bits timestamp.
        '7' || substr(to_hex(get_byte(rand_part, 0)), 2, 1) || -- 4 bits version + 4 bits random.
        substr(to_hex(rand_part), 3, 19) -- 80 bits random.
    )::UUID;
END;
$$ LANGUAGE plpgsql;
