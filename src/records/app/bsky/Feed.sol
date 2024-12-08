// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import "solidity-cbor/tags/ReadCidSha256.sol";
import "solidity-cbor/ReadCbor.sol";
import "../../../repo/ReadStrongRef.sol";

using ReadCbor for bytes;
using ReadCidSha256 for bytes;
using ReadStrongRef for bytes;

library AppBsky {
    bytes18 internal constant nsidFeedLike = "app.bsky.feed.like";
    bytes18 internal constant nsidFeedPost = "app.bsky.feed.post";
    bytes20 internal constant nsidFeedRepost = "app.bsky.feed.repost";

    function readFeedLike(bytes memory cborData) internal pure returns (string memory subject) {
        (uint32 byteIdx, uint mapLen) = cborData.Map(0);

        require(mapLen == 3, "unexpected number of fields");

        bytes32 mapKey;
        for (uint8 mapIdx = 0; mapIdx < mapLen; mapIdx++) {
            (byteIdx, mapKey,) = cborData.String32(byteIdx, 9);
            if (mapKey == "subject") {
                (byteIdx, subject) = cborData.readStrongRef(byteIdx);
            } else if (mapKey == "$type") {
                bytes32 _type;
                (byteIdx, _type,) = cborData.String32(byteIdx, 18);
                require(_type == nsidFeedLike, "unexpected record type");
            } else if (mapKey == "createdAt") {
                // createdAt string unused
                byteIdx = cborData.skipString(byteIdx);
            } else {
                // TODO: ignore unknown keys?
                revert("unexpected record key");
            }
        }
        cborData.requireComplete(byteIdx);

        return subject;
    }

    function readFeedPost(bytes memory cborData) internal pure returns (string memory text) {
        (uint32 byteIdx, uint mapLen) = cborData.Map(0);

        require(mapLen == 4, "unexpected number of fields");

        bytes32 mapKey;
        for (uint mapIdx = 0; mapIdx < mapLen; mapIdx++) {
            (byteIdx, mapKey,) = cborData.String32(byteIdx, 9);
            if (mapKey == "text") {
                (byteIdx, text) = cborData.String(byteIdx);
            } else if (mapKey == "$type") {
                bytes32 _type;
                (byteIdx, _type,) = cborData.String32(byteIdx, 18);
                require(_type == nsidFeedPost, "unexpected record type");
            } else if (mapKey == "langs") {
                // langs array unused
                uint langsLength;
                (byteIdx, langsLength) = cborData.Array(byteIdx);
                for (uint j = 0; j < langsLength; j++) {
                    byteIdx = cborData.skipString(byteIdx);
                }
            } else if (mapKey == "createdAt") {
                // createdAt string unused
                byteIdx = cborData.skipString(byteIdx);
            } else {
                // TODO: ignore unknown keys?
                revert("unexpected record key");
            }
        }
        cborData.requireComplete(byteIdx);

        return text;
    }

    function readFeedRepost(bytes memory cborData) internal pure returns (string memory subject) {
        (uint32 byteIdx, uint mapLen) = cborData.Map(0);

        require(mapLen == 3, "unexpected number of fields");

        bytes32 mapKey;
        for (uint mapIdx = 0; mapIdx < mapLen; mapIdx++) {
            (byteIdx, mapKey,) = cborData.String32(byteIdx, 9);
            if (mapKey == "subject") {
                (byteIdx, subject) = cborData.readStrongRef(byteIdx);
            } else if (mapKey == "$type") {
                bytes32 _type;
                (byteIdx, _type,) = cborData.String32(byteIdx, 20);
                require(_type == nsidFeedRepost, "unexpected record type");
            } else if (mapKey == "createdAt") {
                // createdAt string unused
                byteIdx = cborData.skipString(byteIdx);
            } else {
                // TODO: ignore unknown keys?
                revert("unexpected record key");
            }
        }
        cborData.requireComplete(byteIdx);

        return subject;
    }
}
