//
//  OffsetManagementView.swift
//  lara
//
//  Created by lunginspector on 5/9/26.
//

import SwiftUI

struct OffsetManagementView: View {
    @EnvironmentObject var mgr: laramgr
    
    @State private var editableOffsets: [String: String] = [:]
    @State private var offsetsLoaded: Bool = false
    
    private let offsetNames = [
        "off_inpcb_inp_list_le_next", "off_inpcb_inp_pcbinfo", "off_inpcb_inp_socket",
        "off_inpcbinfo_ipi_zone", "off_inpcb_inp_depend6_inp6_icmp6filt", "off_inpcb_inp_depend6_inp6_chksum",
        "off_socket_so_usecount", "off_socket_so_proto", "off_socket_so_background_thread",
        "off_kalloc_type_view_kt_zv_zv_name",
        "off_thread_t_tro", "off_thread_ro_tro_proc", "off_thread_ro_tro_task",
        "off_thread_machine_upcb", "off_thread_machine_contextdata", "off_thread_ctid",
        "off_thread_options", "off_thread_mutex_lck_mtx_data", "off_thread_machine_kstackptr",
        "off_thread_machine_jop_pid", "off_thread_machine_rop_pid",
        "off_thread_guard_exc_info_code", "off_thread_mach_exc_info_code",
        "off_thread_mach_exc_info_os_reason", "off_thread_mach_exc_info_exception_type",
        "off_thread_ast", "off_thread_task_threads_next",
        "off_proc_p_list_le_next", "off_proc_p_list_le_prev", "off_proc_p_proc_ro",
        "off_proc_p_pid", "off_proc_p_fd", "off_proc_p_flag", "off_proc_p_textvp", "off_proc_p_name",
        "off_proc_ro_pr_task", "off_proc_ro_p_ucred", "off_ucred_cr_label",
        "off_task_itk_space", "off_task_threads_next", "off_task_task_exc_guard", "off_task_map",
        "off_filedesc_fd_ofiles", "off_filedesc_fd_cdir", "off_fileproc_fp_glob",
        "off_fileglob_fg_data", "off_fileglob_fg_flag",
        "off_vnode_v_ncchildren_tqh_first", "off_vnode_v_nclinks_lh_first", "off_vnode_v_parent",
        "off_vnode_v_data", "off_vnode_v_name", "off_vnode_v_usecount", "off_vnode_v_iocount",
        "off_vnode_v_writecount", "off_vnode_v_flag", "off_vnode_v_mount",
        "off_mount_mnt_flag",
        "off_namecache_nc_vp", "off_namecache_nc_child_tqe_next",
        "off_arm_saved_state64_lr", "off_arm_saved_state64_pc", "off_arm_saved_state_uss_ss_64",
        "off_ipc_space_is_table", "off_ipc_entry_ie_object", "off_ipc_port_ip_kobject",
        "off_arm_kernel_saved_state_sp",
        "off_vm_map_hdr", "off_vm_map_header_nentries", "off_vm_map_entry_links_next",
        "off_vm_map_entry_vme_object_or_delta", "off_vm_map_entry_vme_alias",
        "off_vm_map_header_links_next",
        "off_vm_object_vo_un1_vou_size", "off_vm_object_ref_count",
        "off_vm_named_entry_backing_copy", "off_vm_named_entry_size",
        "off_label_l_perpolicy_amfi", "off_label_l_perpolicy_sandbox",
        "sizeof_ipc_entry", "t1sz_boot"
    ]
    
    private let roOffsets = [
        ("smr_base", "smr"), ("VM_MIN_KERNEL_ADDRESS", "vmmin"), ("VM_MAX_KERNEL_ADDRESS", "vmmax")
    ]
    
    init() {
        initOffsetStates()
    }
    
    var body: some View {
        NavigationStack {
            List {
                Button("Save Offsets", action: {
                    saveOffsets()
                })
                
                Section(header: HeaderLabel(text: "Offsets", icon: "tablecells")) {
                    ForEach(offsetNames, id: \.self) { name in
                        HStack {
                            Text(name)
                            Spacer()
                            TextField("0x0", text: Binding(
                                get: { editableOffsets[name, default: "0x0"] },
                                set: { editableOffsets[name] = $0 }
                            ))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                            .monospaced()
                        }
                    }
                }
                
                Section(header: HeaderLabel(text: "Read-Only Offsets", icon: "gear.badge.xmark"), footer: Text("These offsets are read-only and can not be modified.")) {
                    ForEach(roOffsets, id: \.0) { name, key in
                        HStack {
                            Text(name)
                            Spacer()
                            Text(editableOffsets[key, default: "0x0"])
                                .foregroundColor(.secondary)
                                .monospaced()
                        }
                    }
                }
            }
            .navigationTitle("Modify Offsets")
        }
    }
    
    private func saveOffsets() {
        applyOffsetStates()
        savealloffsets()
        mgr.logmsg("Saved all offsets")
    }
    
    private func initOffsetStates() {
        guard !offsetsLoaded else { return }
        var dict: [String: String] = [:]
        dict["off_inpcb_inp_list_le_next"] = String(format: "0x%x", off_inpcb_inp_list_le_next)
        dict["off_inpcb_inp_pcbinfo"] = String(format: "0x%x", off_inpcb_inp_pcbinfo)
        dict["off_inpcb_inp_socket"] = String(format: "0x%x", off_inpcb_inp_socket)
        dict["off_inpcbinfo_ipi_zone"] = String(format: "0x%x", off_inpcbinfo_ipi_zone)
        dict["off_inpcb_inp_depend6_inp6_icmp6filt"] = String(format: "0x%x", off_inpcb_inp_depend6_inp6_icmp6filt)
        dict["off_inpcb_inp_depend6_inp6_chksum"] = String(format: "0x%x", off_inpcb_inp_depend6_inp6_chksum)
        dict["off_socket_so_usecount"] = String(format: "0x%x", off_socket_so_usecount)
        dict["off_socket_so_proto"] = String(format: "0x%x", off_socket_so_proto)
        dict["off_socket_so_background_thread"] = String(format: "0x%x", off_socket_so_background_thread)
        dict["off_kalloc_type_view_kt_zv_zv_name"] = String(format: "0x%x", off_kalloc_type_view_kt_zv_zv_name)
        dict["off_thread_t_tro"] = String(format: "0x%x", off_thread_t_tro)
        dict["off_thread_ro_tro_proc"] = String(format: "0x%x", off_thread_ro_tro_proc)
        dict["off_thread_ro_tro_task"] = String(format: "0x%x", off_thread_ro_tro_task)
        dict["off_thread_machine_upcb"] = String(format: "0x%x", off_thread_machine_upcb)
        dict["off_thread_machine_contextdata"] = String(format: "0x%x", off_thread_machine_contextdata)
        dict["off_thread_ctid"] = String(format: "0x%x", off_thread_ctid)
        dict["off_thread_options"] = String(format: "0x%x", off_thread_options)
        dict["off_thread_mutex_lck_mtx_data"] = String(format: "0x%x", off_thread_mutex_lck_mtx_data)
        dict["off_thread_machine_kstackptr"] = String(format: "0x%x", off_thread_machine_kstackptr)
        dict["off_thread_machine_jop_pid"] = String(format: "0x%x", off_thread_machine_jop_pid)
        dict["off_thread_machine_rop_pid"] = String(format: "0x%x", off_thread_machine_rop_pid)
        dict["off_thread_guard_exc_info_code"] = String(format: "0x%x", off_thread_guard_exc_info_code)
        dict["off_thread_mach_exc_info_code"] = String(format: "0x%x", off_thread_mach_exc_info_code)
        dict["off_thread_mach_exc_info_os_reason"] = String(format: "0x%x", off_thread_mach_exc_info_os_reason)
        dict["off_thread_mach_exc_info_exception_type"] = String(format: "0x%x", off_thread_mach_exc_info_exception_type)
        dict["off_thread_ast"] = String(format: "0x%x", off_thread_ast)
        dict["off_thread_task_threads_next"] = String(format: "0x%x", off_thread_task_threads_next)
        dict["off_proc_p_list_le_next"] = String(format: "0x%x", off_proc_p_list_le_next)
        dict["off_proc_p_list_le_prev"] = String(format: "0x%x", off_proc_p_list_le_prev)
        dict["off_proc_p_proc_ro"] = String(format: "0x%x", off_proc_p_proc_ro)
        dict["off_proc_p_pid"] = String(format: "0x%x", off_proc_p_pid)
        dict["off_proc_p_fd"] = String(format: "0x%x", off_proc_p_fd)
        dict["off_proc_p_flag"] = String(format: "0x%x", off_proc_p_flag)
        dict["off_proc_p_textvp"] = String(format: "0x%x", off_proc_p_textvp)
        dict["off_proc_p_name"] = String(format: "0x%x", off_proc_p_name)
        dict["off_proc_ro_pr_task"] = String(format: "0x%x", off_proc_ro_pr_task)
        dict["off_proc_ro_p_ucred"] = String(format: "0x%x", off_proc_ro_p_ucred)
        dict["off_ucred_cr_label"] = String(format: "0x%x", off_ucred_cr_label)
        dict["off_task_itk_space"] = String(format: "0x%x", off_task_itk_space)
        dict["off_task_threads_next"] = String(format: "0x%x", off_task_threads_next)
        dict["off_task_task_exc_guard"] = String(format: "0x%x", off_task_task_exc_guard)
        dict["off_task_map"] = String(format: "0x%x", off_task_map)
        dict["off_filedesc_fd_ofiles"] = String(format: "0x%x", off_filedesc_fd_ofiles)
        dict["off_filedesc_fd_cdir"] = String(format: "0x%x", off_filedesc_fd_cdir)
        dict["off_fileproc_fp_glob"] = String(format: "0x%x", off_fileproc_fp_glob)
        dict["off_fileglob_fg_data"] = String(format: "0x%x", off_fileglob_fg_data)
        dict["off_fileglob_fg_flag"] = String(format: "0x%x", off_fileglob_fg_flag)
        dict["off_vnode_v_ncchildren_tqh_first"] = String(format: "0x%x", off_vnode_v_ncchildren_tqh_first)
        dict["off_vnode_v_nclinks_lh_first"] = String(format: "0x%x", off_vnode_v_nclinks_lh_first)
        dict["off_vnode_v_parent"] = String(format: "0x%x", off_vnode_v_parent)
        dict["off_vnode_v_data"] = String(format: "0x%x", off_vnode_v_data)
        dict["off_vnode_v_name"] = String(format: "0x%x", off_vnode_v_name)
        dict["off_vnode_v_usecount"] = String(format: "0x%x", off_vnode_v_usecount)
        dict["off_vnode_v_iocount"] = String(format: "0x%x", off_vnode_v_iocount)
        dict["off_vnode_v_writecount"] = String(format: "0x%x", off_vnode_v_writecount)
        dict["off_vnode_v_flag"] = String(format: "0x%x", off_vnode_v_flag)
        dict["off_vnode_v_mount"] = String(format: "0x%x", off_vnode_v_mount)
        dict["off_mount_mnt_flag"] = String(format: "0x%x", off_mount_mnt_flag)
        dict["off_namecache_nc_vp"] = String(format: "0x%x", off_namecache_nc_vp)
        dict["off_namecache_nc_child_tqe_next"] = String(format: "0x%x", off_namecache_nc_child_tqe_next)
        dict["off_arm_saved_state64_lr"] = String(format: "0x%x", off_arm_saved_state64_lr)
        dict["off_arm_saved_state64_pc"] = String(format: "0x%x", off_arm_saved_state64_pc)
        dict["off_arm_saved_state_uss_ss_64"] = String(format: "0x%x", off_arm_saved_state_uss_ss_64)
        dict["off_ipc_space_is_table"] = String(format: "0x%x", off_ipc_space_is_table)
        dict["off_ipc_entry_ie_object"] = String(format: "0x%x", off_ipc_entry_ie_object)
        dict["off_ipc_port_ip_kobject"] = String(format: "0x%x", off_ipc_port_ip_kobject)
        dict["off_arm_kernel_saved_state_sp"] = String(format: "0x%x", off_arm_kernel_saved_state_sp)
        dict["off_vm_map_hdr"] = String(format: "0x%x", off_vm_map_hdr)
        dict["off_vm_map_header_nentries"] = String(format: "0x%x", off_vm_map_header_nentries)
        dict["off_vm_map_entry_links_next"] = String(format: "0x%x", off_vm_map_entry_links_next)
        dict["off_vm_map_entry_vme_object_or_delta"] = String(format: "0x%x", off_vm_map_entry_vme_object_or_delta)
        dict["off_vm_map_entry_vme_alias"] = String(format: "0x%x", off_vm_map_entry_vme_alias)
        dict["off_vm_map_header_links_next"] = String(format: "0x%x", off_vm_map_header_links_next)
        dict["off_vm_object_vo_un1_vou_size"] = String(format: "0x%x", off_vm_object_vo_un1_vou_size)
        dict["off_vm_object_ref_count"] = String(format: "0x%x", off_vm_object_ref_count)
        dict["off_vm_named_entry_backing_copy"] = String(format: "0x%x", off_vm_named_entry_backing_copy)
        dict["off_vm_named_entry_size"] = String(format: "0x%x", off_vm_named_entry_size)
        dict["off_label_l_perpolicy_amfi"] = String(format: "0x%x", off_label_l_perpolicy_amfi)
        dict["off_label_l_perpolicy_sandbox"] = String(format: "0x%x", off_label_l_perpolicy_sandbox)
        dict["sizeof_ipc_entry"] = String(format: "0x%x", sizeof_ipc_entry)
        dict["t1sz_boot"] = String(format: "0x%llx", t1sz_boot)
        dict["smr"] = hex(smr_base)
        dict["vmmin"] = hex(VM_MIN_KERNEL_ADDRESS)
        dict["vmmax"] = hex(VM_MAX_KERNEL_ADDRESS)
        DispatchQueue.main.async {
            editableOffsets = dict
            offsetsLoaded = true
        }
    }
    
    private func applyOffsetStates() {
        func setoff(_ key: String, _ setter: (UInt32) -> Void) {
            if let raw = editableOffsets[key] {
                let cleaned = raw.replacingOccurrences(of: "0x", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                if let value = UInt32(cleaned, radix: 16) { setter(value) }
            }
        }
        setoff("off_inpcb_inp_list_le_next") { off_inpcb_inp_list_le_next = $0 }
        setoff("off_inpcb_inp_pcbinfo") { off_inpcb_inp_pcbinfo = $0 }
        setoff("off_inpcb_inp_socket") { off_inpcb_inp_socket = $0 }
        setoff("off_inpcbinfo_ipi_zone") { off_inpcbinfo_ipi_zone = $0 }
        setoff("off_inpcb_inp_depend6_inp6_icmp6filt") { off_inpcb_inp_depend6_inp6_icmp6filt = $0 }
        setoff("off_inpcb_inp_depend6_inp6_chksum") { off_inpcb_inp_depend6_inp6_chksum = $0 }
        setoff("off_socket_so_usecount") { off_socket_so_usecount = $0 }
        setoff("off_socket_so_proto") { off_socket_so_proto = $0 }
        setoff("off_socket_so_background_thread") { off_socket_so_background_thread = $0 }
        setoff("off_kalloc_type_view_kt_zv_zv_name") { off_kalloc_type_view_kt_zv_zv_name = $0 }
        setoff("off_thread_t_tro") { off_thread_t_tro = $0 }
        setoff("off_thread_ro_tro_proc") { off_thread_ro_tro_proc = $0 }
        setoff("off_thread_ro_tro_task") { off_thread_ro_tro_task = $0 }
        setoff("off_thread_machine_upcb") { off_thread_machine_upcb = $0 }
        setoff("off_thread_machine_contextdata") { off_thread_machine_contextdata = $0 }
        setoff("off_thread_ctid") { off_thread_ctid = $0 }
        setoff("off_thread_options") { off_thread_options = $0 }
        setoff("off_thread_mutex_lck_mtx_data") { off_thread_mutex_lck_mtx_data = $0 }
        setoff("off_thread_machine_kstackptr") { off_thread_machine_kstackptr = $0 }
        setoff("off_thread_machine_jop_pid") { off_thread_machine_jop_pid = $0 }
        setoff("off_thread_machine_rop_pid") { off_thread_machine_rop_pid = $0 }
        setoff("off_thread_guard_exc_info_code") { off_thread_guard_exc_info_code = $0 }
        setoff("off_thread_mach_exc_info_code") { off_thread_mach_exc_info_code = $0 }
        setoff("off_thread_mach_exc_info_os_reason") { off_thread_mach_exc_info_os_reason = $0 }
        setoff("off_thread_mach_exc_info_exception_type") { off_thread_mach_exc_info_exception_type = $0 }
        setoff("off_thread_ast") { off_thread_ast = $0 }
        setoff("off_thread_task_threads_next") { off_thread_task_threads_next = $0 }
        setoff("off_proc_p_list_le_next") { off_proc_p_list_le_next = $0 }
        setoff("off_proc_p_list_le_prev") { off_proc_p_list_le_prev = $0 }
        setoff("off_proc_p_proc_ro") { off_proc_p_proc_ro = $0 }
        setoff("off_proc_p_pid") { off_proc_p_pid = $0 }
        setoff("off_proc_p_fd") { off_proc_p_fd = $0 }
        setoff("off_proc_p_flag") { off_proc_p_flag = $0 }
        setoff("off_proc_p_textvp") { off_proc_p_textvp = $0 }
        setoff("off_proc_p_name") { off_proc_p_name = $0 }
        setoff("off_proc_ro_pr_task") { off_proc_ro_pr_task = $0 }
        setoff("off_proc_ro_p_ucred") { off_proc_ro_p_ucred = $0 }
        setoff("off_ucred_cr_label") { off_ucred_cr_label = $0 }
        setoff("off_task_itk_space") { off_task_itk_space = $0 }
        setoff("off_task_threads_next") { off_task_threads_next = $0 }
        setoff("off_task_task_exc_guard") { off_task_task_exc_guard = $0 }
        setoff("off_task_map") { off_task_map = $0 }
        setoff("off_filedesc_fd_ofiles") { off_filedesc_fd_ofiles = $0 }
        setoff("off_filedesc_fd_cdir") { off_filedesc_fd_cdir = $0 }
        setoff("off_fileproc_fp_glob") { off_fileproc_fp_glob = $0 }
        setoff("off_fileglob_fg_data") { off_fileglob_fg_data = $0 }
        setoff("off_fileglob_fg_flag") { off_fileglob_fg_flag = $0 }
        setoff("off_vnode_v_ncchildren_tqh_first") { off_vnode_v_ncchildren_tqh_first = $0 }
        setoff("off_vnode_v_nclinks_lh_first") { off_vnode_v_nclinks_lh_first = $0 }
        setoff("off_vnode_v_parent") { off_vnode_v_parent = $0 }
        setoff("off_vnode_v_data") { off_vnode_v_data = $0 }
        setoff("off_vnode_v_name") { off_vnode_v_name = $0 }
        setoff("off_vnode_v_usecount") { off_vnode_v_usecount = $0 }
        setoff("off_vnode_v_iocount") { off_vnode_v_iocount = $0 }
        setoff("off_vnode_v_writecount") { off_vnode_v_writecount = $0 }
        setoff("off_vnode_v_flag") { off_vnode_v_flag = $0 }
        setoff("off_vnode_v_mount") { off_vnode_v_mount = $0 }
        setoff("off_mount_mnt_flag") { off_mount_mnt_flag = $0 }
        setoff("off_namecache_nc_vp") { off_namecache_nc_vp = $0 }
        setoff("off_namecache_nc_child_tqe_next") { off_namecache_nc_child_tqe_next = $0 }
        setoff("off_arm_saved_state64_lr") { off_arm_saved_state64_lr = $0 }
        setoff("off_arm_saved_state64_pc") { off_arm_saved_state64_pc = $0 }
        setoff("off_arm_saved_state_uss_ss_64") { off_arm_saved_state_uss_ss_64 = $0 }
        setoff("off_ipc_space_is_table") { off_ipc_space_is_table = $0 }
        setoff("off_ipc_entry_ie_object") { off_ipc_entry_ie_object = $0 }
        setoff("off_ipc_port_ip_kobject") { off_ipc_port_ip_kobject = $0 }
        setoff("off_arm_kernel_saved_state_sp") { off_arm_kernel_saved_state_sp = $0 }
        setoff("off_vm_map_hdr") { off_vm_map_hdr = $0 }
        setoff("off_vm_map_header_nentries") { off_vm_map_header_nentries = $0 }
        setoff("off_vm_map_entry_links_next") { off_vm_map_entry_links_next = $0 }
        setoff("off_vm_map_entry_vme_object_or_delta") { off_vm_map_entry_vme_object_or_delta = $0 }
        setoff("off_vm_map_entry_vme_alias") { off_vm_map_entry_vme_alias = $0 }
        setoff("off_vm_map_header_links_next") { off_vm_map_header_links_next = $0 }
        setoff("off_vm_object_vo_un1_vou_size") { off_vm_object_vo_un1_vou_size = $0 }
        setoff("off_vm_object_ref_count") { off_vm_object_ref_count = $0 }
        setoff("off_vm_named_entry_backing_copy") { off_vm_named_entry_backing_copy = $0 }
        setoff("off_vm_named_entry_size") { off_vm_named_entry_size = $0 }
        setoff("off_label_l_perpolicy_amfi") { off_label_l_perpolicy_amfi = $0 }
        setoff("off_label_l_perpolicy_sandbox") { off_label_l_perpolicy_sandbox = $0 }
        setoff("sizeof_ipc_entry") { sizeof_ipc_entry = $0 }
        if let raw = editableOffsets["t1sz_boot"] {
            let cleaned = raw.replacingOccurrences(of: "0x", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            if let v = UInt64(cleaned, radix: 16) { t1sz_boot = v }
        }
    }
}
