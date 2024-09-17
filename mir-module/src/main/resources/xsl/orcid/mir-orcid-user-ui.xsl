<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="xsl">

  <xsl:param name="MCR.ORCID2.WorkEventHandler.CreateFirstWork" select="'false'"/>
  <xsl:param name="MCR.ORCID2.WorkEventHandler.AlwaysUpdateWork" select="'false'"/>
  <xsl:param name="MCR.ORCID2.WorkEventHandler.CreateDuplicateWork" select="'false'"/>
  <xsl:param name="MCR.ORCID2.WorkEventHandler.RecreateDeletedWork" select="'false'"/>

  <xsl:template name="render-default-orcid-settings">
    <script>
      var mycore = mycore || {};
      mycore["defaultOrcidUserSettings"] = {
        alwaysUpdateWork:<xsl:value-of select='$MCR.ORCID2.WorkEventHandler.AlwaysUpdateWork'/>,
        createDuplicateWork:<xsl:value-of select='$MCR.ORCID2.WorkEventHandler.CreateDuplicateWork'/>,
        createFirstWork:<xsl:value-of select='$MCR.ORCID2.WorkEventHandler.CreateFirstWork'/>,
        recreateDeletedWork:<xsl:value-of select='$MCR.ORCID2.WorkEventHandler.RecreateDeletedWork'/>,
      }
    </script>
  </xsl:template>

  <xsl:template name="render-orcid-settings-modal">
    <div id="orcidSettingsModal" class="modal fade" tabindex="-1" aria-labelledby="orcidSettingsModalLabel" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="orcidSettingsModalLabel">
               <span><xsl:value-of select="document('i18n:mir.orcid.user.settings.modal.title')"/></span>
               <span id="modalTitleOrcid"/>
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body" id="orcid-settings-container">
            <div id="orcidMissingSettingAlert" class="alert alert-danger d-none">
              <xsl:value-of select="document('i18n:mir.orcid.user.settings.validation.incomplete')"/>
            </div>
            <p><xsl:value-of select="document('i18n:mir.orcid.user.settings.work.intro')"/></p>
            <form id="orcidSettingsForm">
              <div class="form-check">
                <input id="createFirstWorkSetting" class="form-check-input" type="checkbox" name="createFirstWork"/>
                <label class="form-check-label" for="createFirstWorkSetting">
                  <xsl:value-of select="document('i18n:mir.orcid.user.settings.work.createFirstWork')"/>
                </label>
              </div>
              <div class="form-check mt-1">
                <input id="alwaysUpdateWorkSetting" class="form-check-input" type="checkbox" name="alwaysUpdateWork"/>
                <label class="form-check-label" for="alwaysUpdateWorkSetting">
                  <xsl:value-of select="document('i18n:mir.orcid.user.settings.work.alwaysUpdateWork')"/>
                </label>
              </div>
              <div class="form-check mt-1">
                <input id="createDuplicateWorkSetting" class="form-check-input" type="checkbox" name="createDuplicateWork"/>
                <label class="form-check-label" for="createDuplicateWorkSetting">
                  <xsl:value-of select="document('i18n:mir.orcid.user.settings.work.createDuplicateWork')"/>
                </label>
              </div>
              <div class="form-check mt-1">
                <input id="recreateDeletedWorkSetting" class="form-check-input" type="checkbox" name="recreateDeletedWork"/>
                <label class="form-check-label" for="recreateDeletedWorkSetting">
                  <xsl:value-of select="document('i18n:mir.orcid.user.settings.work.recreateDeletedWork')"/>
                </label>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button id="saveOrcidSettingsBtn" class="btn btn-primary" type="button">
              <xsl:value-of select="document('i18n:mir.orcid.user.settings.action.save')"/>
            </button>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="render-orcid-oauth-scope-description-list">
    <xsl:param name="scopeString" select="''"/>
    <ul>
      <xsl:if test="contains($scopeString, '/authenticate')">
        <li><xsl:value-of select="document('i18n:component.orcid2.oauth.message.authenticate')"/></li>
      </xsl:if>
      <xsl:if test="contains($scopeString, '/read-limited')">
        <li><xsl:value-of select="document('i18n:component.orcid2.oauth.message.read-limited')"/></li>
      </xsl:if>
      <xsl:if test="contains($scopeString, '/activities/update')">
        <li><xsl:value-of select="document('i18n:component.orcid2.oauth.message.activities_update')"/></li>
      </xsl:if>
      <xsl:if test="contains($scopeString, '/person/update')">
        <li><xsl:value-of select="document('i18n:component.orcid2.oauth.message.person_update')"/></li>
      </xsl:if>
    </ul>
  </xsl:template>

  <xsl:template name="render-show-orcid-oauth-button">
    <xsl:param name="scope"/>
    <xsl:if test="$scope">
      <button id="initOrcidOAuthBtn" type="button" class="btn btn-primary"
        title="{document('i18n:mir.orcid.user.auth.action.link.tooltip')}" data-scope="{$scope}">
        <img alt="ORCID iD" src="{$WebApplicationBaseURL}images/orcid_icon.svg" class="orcid-icon"/>
        <xsl:value-of select="document('i18n:mir.orcid.user.auth.action.link')"/>
      </button>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-revoke-orcid-button">
    <xsl:param name="orcid"/>
    <xsl:if test="$orcid">
      <button type="button" class="btn btn-danger btn-sm ms-2 revoke-orcid-oauth" title="{document('i18n:mir.orcid.user.auth.action.revoke')}"
        data-orcid="{$orcid}" data-redirect-url="{$WebApplicationBaseURL}servlets/MCRUserServlet?action=show">
        <xsl:value-of select="document('i18n:mir.orcid.user.auth.action.revoke')"/>
      </button>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-show-orcid-settings-button">
    <xsl:param name="orcid"/>
    <xsl:if test="$orcid">
      <button type="button" class="btn btn-primary btn-sm ms-2 open-orcid-settings"
        title="{document('i18n:mir.orcid.user.settings.action.open')}" data-orcid="{$orcid}">
        <xsl:value-of select="document('i18n:mir.orcid.user.settings.action.open')"/>
      </button>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-orcid-settings-button-if-required">
    <xsl:param name="orcid"/>
    <xsl:if test="$orcid">
      <xsl:variable name="scopeString" select="document(concat('orcidCredential:scope:', $orcid))/string"/>
      <xsl:if test="contains($scopeString, '/activities/update')">
        <xsl:call-template name="render-show-orcid-settings-button">
          <xsl:with-param name="orcid" select="$orcid"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
