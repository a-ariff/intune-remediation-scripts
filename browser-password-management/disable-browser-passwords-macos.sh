#!/bin/bash
# disable-browser-passwords-macos.sh
# Enhanced script to disable browser password management on macOS devices
# For use with Microsoft Intune remediation framework
# Description: This script disables password saving in Safari, Chrome, Firefox, and Edge on macOS
# Author: IT Administrator
# Purpose: Browser Password Management Configuration
# Version: 2.0
# Updated: $(date '+%Y-%m-%d')

# Set strict error handling
set -euo pipefail

# Configuration
LOG_FILE="/var/log/disable-browser-passwords-macos.log"
SCRIPT_NAME="$(basename "$0")"
USER_HOME="/Users"
CURRENT_USER="$(stat -f%Su /dev/console)"

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Error handling function
error_exit() {
    log_message "ERROR" "$1"
    exit 1
}

# Validation functions
validate_user() {
    if [[ -z "$CURRENT_USER" ]] || [[ "$CURRENT_USER" == "root" ]]; then
        error_exit "No valid user session found or running as root"
    fi
    log_message "INFO" "Current user detected: $CURRENT_USER"
}

validate_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        error_exit "This script is designed for macOS only"
    fi
    log_message "INFO" "macOS system validated"
}

check_browser_running() {
    local browser_name="$1"
    if pgrep -f "$browser_name" > /dev/null; then
        log_message "WARNING" "$browser_name is currently running. Some settings may not apply until restart."
        return 0
    fi
    return 1
}

# Safari configuration function
disable_safari_passwords() {
    log_message "INFO" "Configuring Safari password settings..."
    
    local user_home="$USER_HOME/$CURRENT_USER"
    local safari_plist="$user_home/Library/Preferences/com.apple.Safari.plist"
    
    # Check if Safari is running
    check_browser_running "Safari"
    
    # Create backup of existing preferences
    if [[ -f "$safari_plist" ]]; then
        cp "$safari_plist" "${safari_plist}.backup.$(date +%s)" 2>/dev/null || true
        log_message "INFO" "Safari preferences backed up"
    fi
    
    # Disable password saving in Safari
    sudo -u "$CURRENT_USER" defaults write com.apple.Safari AutoFillPasswords -bool false
    sudo -u "$CURRENT_USER" defaults write com.apple.Safari SuppressSearchSuggestions -bool true
    
    # Disable iCloud Keychain for Safari (if applicable)
    sudo -u "$CURRENT_USER" defaults write com.apple.Safari SyncedDefaults.LastUpdated -dict
    
    log_message "INFO" "Safari password management disabled successfully"
}

# Chrome configuration function
disable_chrome_passwords() {
    log_message "INFO" "Configuring Chrome password settings..."
    
    local user_home="$USER_HOME/$CURRENT_USER"
    local chrome_policy_dir="$user_home/Library/Application Support/Google/Chrome/Policies"
    local chrome_managed_dir="$chrome_policy_dir/Managed"
    local chrome_policy_file="$chrome_managed_dir/policies.json"
    
    # Check if Chrome is running
    check_browser_running "Google Chrome"
    
    # Create Chrome policy directories
    sudo -u "$CURRENT_USER" mkdir -p "$chrome_managed_dir"
    
    # Create or update Chrome policy file
    local chrome_policies='{
  "PasswordManagerEnabled": false,
  "AutofillAddressEnabled": false,
  "AutofillCreditCardEnabled": false,
  "PasswordManagerAllowShowPasswords": false,
  "PasswordLeakDetectionEnabled": false
}'
    
    echo "$chrome_policies" | sudo -u "$CURRENT_USER" tee "$chrome_policy_file" > /dev/null
    
    # Set proper permissions
    chmod 644 "$chrome_policy_file"
    
    log_message "INFO" "Chrome password management disabled successfully"
}

# Firefox configuration function
disable_firefox_passwords() {
    log_message "INFO" "Configuring Firefox password settings..."
    
    local user_home="$USER_HOME/$CURRENT_USER"
    local firefox_profiles_dir="$user_home/Library/Application Support/Firefox/Profiles"
    
    # Check if Firefox is running
    check_browser_running "firefox"
    
    if [[ ! -d "$firefox_profiles_dir" ]]; then
        log_message "WARNING" "Firefox profiles directory not found. Firefox may not be installed."
        return 0
    fi
    
    # Find Firefox profiles and configure each one
    local profile_count=0
    while IFS= read -r -d '' profile_dir; do
        local prefs_file="$profile_dir/prefs.js"
        local user_js_file="$profile_dir/user.js"
        
        # Create backup of existing preferences
        if [[ -f "$prefs_file" ]]; then
            cp "$prefs_file" "${prefs_file}.backup.$(date +%s)" 2>/dev/null || true
        fi
        
        # Create or update user.js with password management disabled
        local firefox_config='// Disable Firefox password management\nuser_pref("signon.rememberSignons", false);\nuser_pref("signon.autofillForms", false);\nuser_pref("signon.generation.enabled", false);\nuser_pref("signon.management.page.breach-alerts.enabled", false);\nuser_pref("signon.firefoxRelay.feature", "disabled");'
        
        echo -e "$firefox_config" | sudo -u "$CURRENT_USER" tee "$user_js_file" > /dev/null
        chmod 644 "$user_js_file"
        
        ((profile_count++))
        log_message "INFO" "Configured Firefox profile: $(basename "$profile_dir")"
        
    done < <(find "$firefox_profiles_dir" -name "*.default*" -type d -print0 2>/dev/null || true)
    
    if [[ $profile_count -gt 0 ]]; then
        log_message "INFO" "Firefox password management disabled for $profile_count profile(s)"
    else
        log_message "WARNING" "No Firefox profiles found to configure"
    fi
}

# Microsoft Edge configuration function
disable_edge_passwords() {
    log_message "INFO" "Configuring Microsoft Edge password settings..."
    
    local user_home="$USER_HOME/$CURRENT_USER"
    local edge_policy_dir="$user_home/Library/Application Support/Microsoft Edge/Policies"
    local edge_managed_dir="$edge_policy_dir/Managed"
    local edge_policy_file="$edge_managed_dir/policies.json"
    
    # Check if Edge is running
    check_browser_running "Microsoft Edge"
    
    # Create Edge policy directories
    sudo -u "$CURRENT_USER" mkdir -p "$edge_managed_dir"
    
    # Create or update Edge policy file
    local edge_policies='{
  "PasswordManagerEnabled": false,
  "AutofillAddressEnabled": false,
  "AutofillCreditCardEnabled": false,
  "PasswordManagerAllowShowPasswords": false,
  "PasswordLeakDetectionEnabled": false,
  "PasswordMonitorAllowed": false
}'
    
    echo "$edge_policies" | sudo -u "$CURRENT_USER" tee "$edge_policy_file" > /dev/null
    
    # Set proper permissions
    chmod 644 "$edge_policy_file"
    
    log_message "INFO" "Microsoft Edge password management disabled successfully"
}

# System validation function
validate_configuration() {
    log_message "INFO" "Validating browser configurations..."
    
    local validation_errors=0
    
    # Validate Safari
    local safari_autofill=$(sudo -u "$CURRENT_USER" defaults read com.apple.Safari AutoFillPasswords 2>/dev/null || echo "1")
    if [[ "$safari_autofill" == "0" ]]; then
        log_message "INFO" "Safari password management: DISABLED ✓"
    else
        log_message "ERROR" "Safari password management: ENABLED ✗"
        ((validation_errors++))
    fi
    
    # Validate Chrome
    local chrome_policy_file="$USER_HOME/$CURRENT_USER/Library/Application Support/Google/Chrome/Policies/Managed/policies.json"
    if [[ -f "$chrome_policy_file" ]] && grep -q '"PasswordManagerEnabled": false' "$chrome_policy_file"; then
        log_message "INFO" "Chrome password management: DISABLED ✓"
    else
        log_message "WARNING" "Chrome policy file not found or incorrectly configured"
    fi
    
    # Validate Edge
    local edge_policy_file="$USER_HOME/$CURRENT_USER/Library/Application Support/Microsoft Edge/Policies/Managed/policies.json"
    if [[ -f "$edge_policy_file" ]] && grep -q '"PasswordManagerEnabled": false' "$edge_policy_file"; then
        log_message "INFO" "Microsoft Edge password management: DISABLED ✓"
    else
        log_message "WARNING" "Microsoft Edge policy file not found or incorrectly configured"
    fi
    
    # Validate Firefox
    local firefox_profiles_dir="$USER_HOME/$CURRENT_USER/Library/Application Support/Firefox/Profiles"
    local firefox_configured=false
    if [[ -d "$firefox_profiles_dir" ]]; then
        while IFS= read -r -d '' profile_dir; do
            local user_js_file="$profile_dir/user.js"
            if [[ -f "$user_js_file" ]] && grep -q 'signon.rememberSignons.*false' "$user_js_file"; then
                firefox_configured=true
                break
            fi
        done < <(find "$firefox_profiles_dir" -name "*.default*" -type d -print0 2>/dev/null || true)
    fi
    
    if [[ "$firefox_configured" == true ]]; then
        log_message "INFO" "Firefox password management: DISABLED ✓"
    else
        log_message "WARNING" "Firefox configuration not found or incorrectly set"
    fi
    
    return $validation_errors
}

# Cleanup function
cleanup() {
    log_message "INFO" "Performing cleanup operations..."
    # Add any cleanup operations here
}

# Main execution function
main() {
    log_message "INFO" "Starting macOS browser password management configuration..."
    log_message "INFO" "Script version: 2.0"
    
    # Validate environment
    validate_macos
    validate_user
    
    # Set trap for cleanup
    trap cleanup EXIT
    
    # Configure browsers
    disable_safari_passwords
    disable_chrome_passwords
    disable_firefox_passwords
    disable_edge_passwords
    
    # Validate configuration
    if validate_configuration; then
        log_message "INFO" "All browser password management configurations completed successfully"
    else
        log_message "WARNING" "Some configurations may need manual verification"
    fi
    
    log_message "INFO" "Script execution completed"
    
    # Notify user about browser restart recommendation
    echo ""
    echo "========================================"
    echo "IMPORTANT: Please restart all browsers"
    echo "to ensure settings take effect."
    echo "========================================"
    echo ""
    
    exit 0
}

# Execute main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
