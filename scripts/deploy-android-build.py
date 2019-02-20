#!/usr/bin/python3

import os
import subprocess
import sys

CLUSTER_MACHINE = '10.100.1.2'
CLUSTER_FRONTEND = 'zookeeper.cs.washington.edu'
CLUSTER_USERNAME = 'nl35'
USING_VPN = True

PRODUCT_DIR = 'out/target/product'
LIBART_PATH = 'obj/lib/libart.so'
CLUSTER_TEMP_DIR = '/biggerraid/users/nl35/temp'
ANDROID_TEMP_DIR = '/storage/emulated/0/Download'

LOCAL_TEMP_DIR = '/home/nl35/research/android-memory-model/temp'
#LOCAL_TEMP_DIR = 'C:\\Users\\niell\\Research\\android-memory-model\\temp'

DEVICE_CONFIGS = [
    # device name, product name, is production build?, Android source dir on cluster, preferred boot slot
    ['emulator-5554', 'generic_x86', False, '/scratch/nl35/android-source-7.1.1_r57', None],
    ['ZY222WW2LM', 'shamu', False, '/scratch/nl35/android-source-7.1.1_r57', None],
    ['HT75G0200488', 'marlin', False, '/scratch/nl35/android-source-7.1.1_r57', 'a'],
    ['HT75K0204567', 'marlin', False, '/scratch/nl35/android-source-7.1.1_r57', 'b'],
    ]

def get_device_name():
    completed_proc = subprocess.run(['adb', 'devices'], stdout=subprocess.PIPE)
    out_split = completed_proc.stdout.decode('utf-8').split('\n')
    if len(out_split) == 4:
        device_line_split = out_split[1].split()
        if len(device_line_split) == 2 and device_line_split[1] == 'device':
            return device_line_split[0]
    return None

def is_emulator(device_name):
    return device_name.count('emulator')

def do_sanity_checks(device_name, product_name, android_source_dir):
    check_result = True

    if device_name == None:
        check_result = False
        print('Sanity check failed: no device (or multiple devices) detected')
    if product_name == None:
        check_result = False
        print('Sanity check failed: no product name')
    if android_source_dir == None:
        check_result = False
        print('Sanity check failed: no Android source dir')
    if not os.path.isdir(LOCAL_TEMP_DIR):
        check_result = False
        print('Sanity check failed: local temp dir does not exist')

    return check_result

def do_libart_sanity_checks(device_name, product_name, android_source_dir):
    check_result = True

    check_libart_backup_cmd = run_adb_shell_command('ls /system/lib/libart.so.backup')

    if check_libart_backup_cmd.returncode or check_libart_backup_cmd.stdout.decode('utf-8').find('No such file or directory') != -1:
        check_result = False
        print('Sanity check failed: no backup of libart.so on device')

    return check_result

def load_config(device_name):
    result_config_list = None
    num_configs = 0
    for config in DEVICE_CONFIGS:
        if len(config) == 5 and config[0] == device_name:
            result_config_list = config
            num_configs += 1
    if num_configs != 1:
        return None, None, None, None
    return result_config_list[1], result_config_list[2], result_config_list[3], result_config_list[4]

def run_adb_shell_command(cmd, as_root=False):
    if as_root:
        cmd = 'su -c ' + cmd
    return subprocess.run(['adb', 'shell', cmd], stdout=subprocess.PIPE)

def run_ssh_command(cmd):
    if USING_VPN:
        if os.name == 'nt':
            print('Using Windows with VPN is not implemented yet')
        else:
            return subprocess.run(['ssh', CLUSTER_USERNAME + '@' + CLUSTER_MACHINE + ' ' + cmd])
    else:
        if os.name == 'nt':
            return subprocess.run(['winscp.com', '/command', 'open ' + CLUSTER_USERNAME + '@' + CLUSTER_FRONTEND, 'call ssh ' + CLUSTER_MACHINE + ' ' + cmd, 'exit'])
        else:
            return subprocess.run(['ssh', CLUSTER_USERNAME + '@' + CLUSTER_FRONTEND, 'ssh ' + CLUSTER_MACHINE + ' ' + cmd])

def copy_file(remote_path, local_path):
    if USING_VPN:
        if os.name == 'nt':
            print('Using Windows with VPN is not implemented yet')
        else:
            return subprocess.run(['scp', CLUSTER_USERNAME + '@' + CLUSTER_MACHINE + ':' + remote_path, local_path])
    if os.name == 'nt':
        if os.path.isdir(local_path):
            local_path = os.path.join(local_path, os.sep)
        return subprocess.run(['winscp.com', '/command', 'open ' + CLUSTER_USERNAME + '@' + CLUSTER_FRONTEND, 'get ' + remote_path + ' ' + local_path, 'exit'])
    else:
        return subprocess.run(['scp', CLUSTER_USERNAME + '@' + CLUSTER_FRONTEND + ':' + remote_path, local_path])

def deploy_libart_so(device_name, product_name, is_production_build, android_source_dir):
    if not do_libart_sanity_checks(device_name, product_name, android_source_dir):
        print('libart-specific sanity checks failed')
        return
    if USING_VPN:
        print('Not implemented yet')
        return

    local_temp_libart_path = os.path.join(LOCAL_TEMP_DIR, 'libart.so')

    run_ssh_command('mkdir -p ' + CLUSTER_TEMP_DIR)
    run_ssh_command('rm ' + CLUSTER_TEMP_DIR + '/*')
    run_ssh_command('cp ' + android_source_dir + '/' + PRODUCT_DIR + '/' + product_name + '/' + LIBART_PATH + ' ' + CLUSTER_TEMP_DIR + '/libart.so')

    if os.path.exists(local_temp_libart_path):
        os.remove(local_temp_libart_path)
    copy_file(CLUSTER_TEMP_DIR + '/libart.so', local_temp_libart_path)

    if is_production_build:
        run_adb_shell_command('mount -o rw,remount /system', True)
    else:
        subprocess.run(['adb', 'root'])
        subprocess.run(['adb', 'remount'])

    subprocess.run(['adb', 'push', local_temp_libart_path, ANDROID_TEMP_DIR])

    as_root = False
    if is_production_build:
        as_root = True

    run_adb_shell_command('mv ' + ANDROID_TEMP_DIR + '/libart.so /system/lib', as_root)
    run_adb_shell_command('chmod g-w,a+r /system/lib/libart.so', as_root)
    run_adb_shell_command('chown root:root /system/lib/libart.so', as_root)

# Return a dictionary mapping image names to the correct partition names
def get_image_dict(product_name, preferred_boot_slot):
    if product_name == 'shamu':
        return {'boot.img':'boot', 'recovery.img':'recovery', 'system.img':'system'}
    elif product_name == 'marlin' and preferred_boot_slot == 'a':
        return {'boot.img':'boot', 'system.img':'system', 'system_other.img':'system_b'}
    elif product_name == 'marlin' and preferred_boot_slot == 'b':
        return {'boot.img':'boot', 'system.img':'system', 'system_other.img':'system_a'}
    else:
        return None

# Copy system images from the cluster onto the local machine, and flash
# them onto the connected Android device.
def deploy_system_image(device_name, product_name, android_source_dir, preferred_boot_slot):
    image_dict = get_image_dict(product_name, preferred_boot_slot)
    if image_dict is None:
        print('No image-to-partition mapping provided for product ' + product_name + ' and preferred boot slot ' + repr(preferred_boot_slot))
        return

    source_img_dir = android_source_dir + '/' + PRODUCT_DIR + '/' + product_name
    cluster_img_dir = source_img_dir if USING_VPN else CLUSTER_TEMP_DIR

    if not USING_VPN:
        run_ssh_command('mkdir -p ' + CLUSTER_TEMP_DIR)
        run_ssh_command('rm ' + CLUSTER_TEMP_DIR + '/*.img')
        for image_name in image_dict:
            print('Copying ' + image_name + ' into cluster temp dir...')
            run_ssh_command('cp ' + source_img_dir + '/' + image_name + ' ' + CLUSTER_TEMP_DIR)

    # delete all img files in LOCAL_TEMP_DIR
    files = os.listdir(LOCAL_TEMP_DIR)
    for fyle in files:
        if fyle.endswith('.img'):
            os.remove(os.path.join(LOCAL_TEMP_DIR, fyle))

    for image_name in image_dict:
        copy_file(cluster_img_dir + '/' + image_name, LOCAL_TEMP_DIR)

    subprocess.run(['adb', 'reboot', 'bootloader'])
    for image_name in image_dict:
        subprocess.run(['fastboot', 'flash', image_dict[image_name], os.path.join(LOCAL_TEMP_DIR, image_name)])
    subprocess.run(['fastboot', 'reboot'])


def main():
    device_name = get_device_name()
    product_name, is_production_build, android_source_dir, preferred_boot_slot = load_config(device_name)

    if not do_sanity_checks(device_name, product_name, android_source_dir):
        print('Sanity checks failed')
        return

    print('Detected device %s; using product_name %s, android_source_dir %s, preferred_boot_slot %s'
          % (device_name, product_name, android_source_dir, repr(preferred_boot_slot)))

    #deploy_libart_so(device_name, product_name, is_production_build, android_source_dir)
    deploy_system_image(device_name, product_name, android_source_dir, preferred_boot_slot);

if __name__ == '__main__':
    main()
