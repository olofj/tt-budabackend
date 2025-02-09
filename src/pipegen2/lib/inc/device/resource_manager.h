// SPDX-FileCopyrightText: © 2024 Tenstorrent AI ULC
//
// SPDX-License-Identifier: Apache-2.0
#pragma once

#include <memory>
#include <unordered_map>
#include <unordered_set>

#include "device/tt_xy_pair.h"
#include "netlist/tt_backend_api_types.hpp"

#include "device/soc_info.h"
#include "model/typedefs.h"

namespace pipegen2
{
    class CoreResources;
    class WorkerCoreResources;
    class EthernetCoreResources;

    class ResourceManager
    {
    public:
        // Constructs resource manager based on SoC info.
        ResourceManager(std::unique_ptr<SoCInfo> soc_info);

        // Destructor, necessary for forward declarations of classes in smart pointer members.
        ~ResourceManager();

        // Allocates stream on a given worker core for transfer from the packer and returns its ID.
        StreamId allocate_packer_stream(const tt_cxy_pair& worker_core_physical_location, int operand_id);

        // Allocates stream on a given worker core for transfer to the unpacker and returns its ID.
        StreamId allocate_unpacker_stream(const tt_cxy_pair& worker_core_physical_location, int operand_id);

        // Allocates intermediate stream on a given worker core and returns its ID.
        StreamId allocate_intermed_stream(const tt_cxy_pair& worker_core_physical_location, int operand_id);

        // Allocates stream on a given core with capability of gathering and returns its ID.
        StreamId allocate_gather_stream(const tt_cxy_pair& core_physical_location);

        // Allocates stream on a given core with capability of multicasting and returns its ID.
        StreamId allocate_multicast_stream(const tt_cxy_pair& core_physical_location);

        // Allocates packer-multicast stream on a given worker core and returns its ID.
        StreamId allocate_packer_multicast_stream(const tt_cxy_pair& worker_core_physical_location, int operand_id);

        // Allocates extra stream on a given core with general purpose capabilities and returns its ID.
        StreamId allocate_general_purpose_stream(const tt_cxy_pair& core_physical_location);

        // Allocates stream on a given ethernet core with capability of transferring data over ethernet and returns its
        // ID.
        StreamId allocate_ethernet_stream(const tt_cxy_pair& eth_core_physical_location);

        // Allocates extra space in L1 memory of each core on each chip, reserved for message info buffer tile headers.
        // Memory is allocated at the beginning of L1 data buffers space. By default each core gets a segment in L1
        // memory for tile headers buffer, but if there are multiple different tile headers on a core, then we need to
        // allocate extra buffers for them. This function allocates extra space for all cores on all chips.
        void allocate_l1_extra_tile_headers_space(
            const std::unordered_map<tt_cxy_pair, std::unordered_set<unsigned int>>& core_to_msg_sizes);

        // If given blob size is greater than minimum blob size required for a given core, then allocates extra space
        // and returns the extra amount needed. Memory is allocated at the beginning of L1 data buffers space.
        unsigned int allocate_l1_extra_overlay_blob_space(const tt_cxy_pair& core_physical_location,
                                                          unsigned int blob_size_in_bytes);

        // Allocates memory for data buffer in L1 on a given core and returns the allocation address.
        // Memory is allocated from the end of L1 data buffers space towards beginning.
        unsigned int allocate_core_l1_data_buffer(const tt_cxy_pair& core_physical_location,
                                                  unsigned int size_in_bytes);

        // Allocates kernel input on a given core and returns its index.
        unsigned int allocate_kernel_input(const tt_cxy_pair& core_physical_location);

        // Allocates kernel output on a given core and returns its index.
        unsigned int allocate_kernel_output(const tt_cxy_pair& core_physical_location);

        // Returns SoC info.
        const SoCInfo* get_soc_info() const { return m_soc_info.get(); }

        // Returns whether a given core is an Ethernet core.
        bool is_ethernet_core(const tt_cxy_pair& core_physical_location) const
        {
            return m_eth_cores_resources.find(core_physical_location) != m_eth_cores_resources.end();
        }

        // Returns total number of multicast streams available on a core with given location.
        unsigned int get_multicast_streams_count(const tt_cxy_pair& core_physical_location) const;

    private:
        // Creates appropriate worker core resources for a given device architecture and worker core location.
        std::unique_ptr<WorkerCoreResources> create_worker_core_resources(tt::ARCH device_arch,
                                                                          const tt_cxy_pair& core_physical_location);

        // Creates appropriate ethernet core resources for a given device architecture and ethernet core location.
        std::unique_ptr<EthernetCoreResources> create_eth_core_resources(tt::ARCH device_arch,
                                                                         const tt_cxy_pair& core_physical_location);

        // Gets worker core resources for a given worker core location.
        WorkerCoreResources* get_worker_core_resources(const tt_cxy_pair& core_physical_location) const;

        // Gets ethernet core resources for a given ethernet core location.
        EthernetCoreResources* get_eth_core_resources(const tt_cxy_pair& core_physical_location) const;

        // Gets core resources for a given core location.
        CoreResources* get_core_resources(const tt_cxy_pair& core_physical_location) const;

        // Holds all chip info.
        std::unique_ptr<SoCInfo> m_soc_info;

        // Map of resources for each worker core on each chip, mapped by their physical coordinates.
        std::unordered_map<tt_cxy_pair, std::unique_ptr<WorkerCoreResources>> m_worker_cores_resources;

        // Map of resources for each eth core on each chip, mapped by their physical coordinates.
        std::unordered_map<tt_cxy_pair, std::unique_ptr<EthernetCoreResources>> m_eth_cores_resources;
    };
}