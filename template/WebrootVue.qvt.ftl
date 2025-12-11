<#--
This software is in the public domain under CC0 1.0 Universal plus a
Grant of Patent License.

To the extent possible under law, the author(s) have dedicated all
copyright and related and neighboring rights to this software to the
public domain worldwide. This software is distributed without any
warranty.

You should have received a copy of the CC0 Public Domain Dedication
along with this software (see the LICENSE.md file). If not, see
<http://creativecommons.org/publicdomain/zero/1.0/>.
-->
<div id="apps-root" style="display:none;"><#-- NOTE: webrootVue component attaches here, uses this and below for template -->
    <input type="hidden" id="confMoquiSessionToken" value="${ec.web.sessionToken}">
    <input type="hidden" id="confAppHost" value="${ec.web.getHostName(true)}">
    <input type="hidden" id="confAppRootPath" value="${ec.web.servletContext.contextPath}">
    <input type="hidden" id="confBasePath" value="${ec.web.servletContext.contextPath}/apps">
    <input type="hidden" id="confLinkBasePath" value="${ec.web.servletContext.contextPath}/dapps">
    <input type="hidden" id="confUserId" value="${ec.user.userId!''}">
    <input type="hidden" id="confUsername" value="${ec.user.username!''}">
    <#-- TODO get secondFactorRequired (org.moqui.impl.UserServices.get#UserAuthcFactorRequired with userId) -->
    <input type="hidden" id="confLocale" value="${ec.user.locale.toLanguageTag()}">
    <input type="hidden" id="confDarkMode" value="${ec.user.getPreference("QUASAR_DARK")!"false"}">
    <input type="hidden" id="confLeftOpen" value="${ec.user.getPreference("QUASAR_LEFT_OPEN")!"false"}">
    <#assign navbarCompList = sri.getThemeValues("STRT_HEADER_NAVBAR_COMP")>
    <#list navbarCompList! as navbarCompUrl><input type="hidden" class="confNavPluginUrl" value="${navbarCompUrl}"></#list>
    <#assign accountCompList = sri.getThemeValues("STRT_HEADER_ACCOUNT_COMP")>
    <#list accountCompList! as accountCompUrl><input type="hidden" class="confAccountPluginUrl" value="${accountCompUrl}"></#list>

    <#assign headerClass = "bg-black text-white">

    <#-- for layout options see: https://quasar.dev/layout/layout -->
    <#-- to build a layout use the handy Quasar tool: https://quasar.dev/layout-builder -->
    <q-layout view="hHh LpR fFf">

    <!-- DURION  -->
    <q-header class="durion-header" elevated>
        <q-toolbar>

            <!-- Left: Logo + Titles -->
            <div class="row items-center q-gutter-sm">
                <q-avatar square size="32px">
                    <img src="/durion-theme/webroot/img/durion-badge-med.png" alt="Durion Logo">
                </q-avatar>

                <div class="column">
                    <div class="durion-header__title">
                        Durion 
                    </div>
                    <div class="durion-header__subtitle">
                       Enterprise Tire Service Management System
                    </div>
                </div>
            </div>

            <!-- Spacer pushes center/right content away -->
            <q-space/>

            <!-- Center (optional): current app / screen name -->
            <div class="q-mr-md gt-sm">
                <span class="text-weight-medium">
                    {{ currentAppTitle }}
                </span>
                <span class="text-caption q-ml-xs text-grey-4" v-if="currentSubscreenTitle">
                    · {{ currentSubscreenTitle }}
                </span>
            </div>

            <!-- Right: Sponsor badge + user menu -->
            <div class="row items-center q-gutter-md">

                <!-- Michelin-style sponsor badge -->
                <div class="durion-header__sponsor">
                    <span>Technology partner:</span>
                    <q-avatar square size="40px">
                        <img src="/durion-theme/webroot/img/sponsor-michelin-badge.svg"
                             alt="Michelin">
                    </q-avatar>
                </div>

                <!-- Existing user menu / profile dropdown -->
                <q-btn dense round flat icon="account_circle">
                    <q-menu>
                        <!-- keep your existing user menu content here -->
                        <q-list style="min-width: 180px">
                            <q-item clickable v-close-popup @click="logout">
                                <q-item-section>Sign out</q-item-section>
                            </q-item>
                            <!-- etc… -->
                        </q-list>
                    </q-menu>
                </q-btn>
            </div>

        </q-toolbar>
    </q-header>

   
        <q-drawer v-model="leftOpen" side="left" bordered><#-- no 'overlay', for those who want to keep it open better to compress main area -->
            <q-btn dense flat icon="menu" @click="toggleLeftOpen()" class="lt-sm"></q-btn>
            <q-list dense padding><m-menu-nav-item :menu-index="0"></m-menu-nav-item></q-list>
        </q-drawer>

        <q-page-container class="q-ma-sm"><q-page>
            <m-subscreens-active></m-subscreens-active>
        </q-page></q-page-container>

        <q-footer class="bg-grey-9 text-grey-3">
    <q-toolbar>

        <div>
            Durion Enterprise Tire Service Management System · v{{ durionVersion }}
        </div>

        <q-space/>

        <div class="text-caption">
            &copy; {{ new Date().getFullYear() }} Durion Systems. All rights reserved.
        </div>

    </q-toolbar>
</q-footer>

    </q-layout>
    <#-- re-login dialog -->
    <m-dialog v-model="reLoginShow" width="400" title="${ec.l10n.localize("Re-Login")}">
        <div v-if="reLoginMfaData">
            <div style="text-align:center;padding-bottom:10px">User <strong>{{username}}</strong> requires an authentication code, you have these options:</div>
            <div style="text-align:center;padding-bottom:10px">{{reLoginMfaData.factorTypeDescriptions.join(", ")}}</div>
            <q-form @submit.prevent="reLoginVerifyOtp" autocapitalize="off" autocomplete="off">
                <q-input v-model="reLoginOtp" name="code" type="password" :autofocus="true" :noPassToggle="false"
                         outlined stack-label label="${ec.l10n.localize("Authentication Code")}"></q-input>
                <q-btn outline no-caps color="primary" type="submit" label="${ec.l10n.localize("Sign in")}"></q-btn>
            </q-form>
            <div v-for="sendableFactor in reLoginMfaData.sendableFactors" style="padding:8px">
                <q-btn outline no-caps dense
                       :label="'${ec.l10n.localize("Send code to")} ' + sendableFactor.factorOption"
                       @click.prevent="reLoginSendOtp(sendableFactor.factorId)"></q-btn>
            </div>
        </div>
        <div v-else>
            <div style="text-align:center;padding-bottom:10px">Please sign in to continue as user <strong>{{username}}</strong></div>
            <q-form @submit.prevent="reLoginSubmit" autocapitalize="off" autocomplete="off">
                <q-input v-model="reLoginPassword" name="password" type="password" :autofocus="true"
                         outlined stack-label label="${ec.l10n.localize("Password")}"></q-input>
                <q-btn outline no-caps color="primary" type="submit" label="${ec.l10n.localize("Sign in")}"></q-btn>
                <q-btn outline no-caps color="negative" @click.prevent="reLoginReload" label="${ec.l10n.localize("Reload Page")}"></q-btn>
            </q-form>
        </div>
    </m-dialog>
</div>

<script>
    window.quasarConfig = {
        brand: { // this will NOT work on IE 11
            // primary: '#e46262',
            info:'#1e7b8e'
        },
        notify: { progress:true, closeBtn:'X', position:'top-right' }, // default set of options for Notify Quasar plugin
        // loading: {...}, // default set of options for Loading Quasar plugin
        loadingBar: { color:'primary' }, // settings for LoadingBar Quasar plugin
        // ..and many more (check Installation card on each Quasar component/directive/plugin)
    }
</script>