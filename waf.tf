#WAF2 Main
resource "aws_wafv2_web_acl" "WafWebAcl" {
  name = "WAF_Common_Protections"
  scope = "REGIONAL"

  default_action {
    allow {
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name = "WAF_Common_Protections"
    sampled_requests_enabled = false
  }

  rule {
    name = "AWSManagedRulesCommonRule"
    priority = 1

    override_action {
      none {
      }
    }

    statement {
      managed_rule_group_statement {
        name = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          action_to_use {
            allow {}
          }
          name = "NoUserAgent_HEADER"
        }
        rule_action_override {
          action_to_use {
            allow {}
          }
          name = "SizeRestrictions_BODY"
        }
        rule_action_override {
          action_to_use {
            allow {}
          }
          name = "CrossSiteScripting_BODY"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name = "AWSManagedRulesCommonRule"
      sampled_requests_enabled = false
    }
  }

  rule {
    name = "AWSManagedRulesKnownBadInputsRule"
    priority = 2
    override_action {
      none {
      }
    }
    statement {
      managed_rule_group_statement {
        name = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name = "AWSManagedRulesKnownBadInputsRule"
      sampled_requests_enabled = false
    }
  }
  rule {
    name = "AWSManagedRulesAmazonIpReputation"
    priority = 3
    override_action {
      none {
      }
    }
    statement {
      managed_rule_group_statement {
        name = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name = "AWSManagedRulesAmazonIpReputation"
      sampled_requests_enabled = false
    }
  }
  rule {
    name = "AWSManagedRulesSQLDatabase"
    priority = 4
    override_action {
      none {
      }
    }
    statement {
      managed_rule_group_statement {
        name = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name = "AWSManagedRulesSQLDatabase"
      sampled_requests_enabled = false
    }
  }
  rule {
    name = "AWSManagedRulesLinuxOperatingSystem"
    priority = 5
    override_action {
      none {
      }
    }
    statement {
      managed_rule_group_statement {
        name = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name = "AWSManagedRulesLinuxOperatingSystem"
      sampled_requests_enabled = false
    }
  }
}
#WAF2 Squidex
resource "aws_wafv2_web_acl" "WafWebAcl_Squidex" {
  name = "WAF_Common_Protections_Squidex"
  scope = "REGIONAL"

  default_action {
    allow {
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name = "WAF_Common_Protections"
    sampled_requests_enabled = false
  }

  rule {
    name = "AWSManagedRulesCommonRule"
    priority = 1

    override_action {
      none {
      }
    }

    statement {
      managed_rule_group_statement {
        name = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        
        rule_action_override {
          action_to_use {
            allow {}
          }
          name = "NoUserAgent_HEADER"
        }
        rule_action_override {
          action_to_use {
            allow {}
          }
          name = "SizeRestrictions_BODY"
        }
        rule_action_override {
          action_to_use {
            allow {}
          }
          name = "CrossSiteScripting_BODY"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name = "AWSManagedRulesCommonRule"
      sampled_requests_enabled = false
    }
  }

  rule {
    name = "AWSManagedRulesKnownBadInputsRule"
    priority = 2
    override_action {
      none {
      }
    }
    statement {
      managed_rule_group_statement {
        name = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name = "AWSManagedRulesKnownBadInputsRule"
      sampled_requests_enabled = false
    }
  }
  rule {
    name = "AWSManagedRulesAmazonIpReputation"
    priority = 3
    override_action {
      none {
      }
    }
    statement {
      managed_rule_group_statement {
        name = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"

        rule_action_override {
          action_to_use {
            allow {}
          }
          name = "AWSManagedIPReputationList"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name = "AWSManagedRulesAmazonIpReputation"
      sampled_requests_enabled = false
    }
  }
  rule {
    name = "AWSManagedRulesSQLDatabase"
    priority = 4
    override_action {
      none {
      }
    }
    statement {
      managed_rule_group_statement {
        name = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name = "AWSManagedRulesSQLDatabase"
      sampled_requests_enabled = false
    }
  }
  rule {
    name = "AWSManagedRulesLinuxOperatingSystem"
    priority = 5
    override_action {
      none {
      }
    }
    statement {
      managed_rule_group_statement {
        name = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name = "AWSManagedRulesLinuxOperatingSystem"
      sampled_requests_enabled = false
    }
  }
}
