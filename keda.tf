# Copyright (C) Nicolas Lamirault <nicolas.lamirault@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

module "service_account" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "4.2.1"

  project_id = var.project

  names = [
    format("%s-sa", local.service)
  ]

  project_roles = [
    format("%s=>roles/monitoring.viewer", var.project),
  ]
}

module "iam_service_accounts" {
  source  = "terraform-google-modules/iam/google//modules/service_accounts_iam"
  version = "7.6.0"

  project = var.project
  mode    = "additive"

  service_accounts = [
    # https://github.com/terraform-google-modules/terraform-google-cloud-storage/issues/142
    # module.service_account.email
    format("%s@%s.iam.gserviceaccount.com", local.service, var.project),
  ]

  bindings = {
    "roles/iam.workloadIdentityUser" = [
      format("serviceAccount:%s.svc.id.goog[%s/%s]", var.project, var.namespace, var.service_account)
    ]
  }
}
