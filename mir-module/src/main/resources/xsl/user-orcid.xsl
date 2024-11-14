<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xsl">

  <xsl:param name="MCR.ORCID2.WorkEventHandler.CreateFirstWork" select="'false'"/>
  <xsl:param name="MCR.ORCID2.WorkEventHandler.AlwaysUpdateWork" select="'false'"/>
  <xsl:param name="MCR.ORCID2.WorkEventHandler.CreateDuplicateWork" select="'false'"/>
  <xsl:param name="MCR.ORCID2.WorkEventHandler.RecreateDeletedWork" select="'false'"/>

  <xsl:template name="printOrcidSettingsModal">
    <div id="orcid-settings-modal" class="modal fade" tabindex="-1" aria-labelledby="orcid-settings-modal-label"
      aria-hidden="true" data-create-first-work="{$MCR.ORCID2.WorkEventHandler.CreateFirstWork}"
      data-always-update-work="{$MCR.ORCID2.WorkEventHandler.AlwaysUpdateWork}"
      data-create-duplicate-work="{$MCR.ORCID2.WorkEventHandler.CreateDuplicateWork}"
      data-recreate-deleted-work="{$MCR.ORCID2.WorkEventHandler.RecreateDeletedWork}">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="orcid-settings-modal-label">
               <span><xsl:value-of select="document('i18n:orcid.settingsModal.headline')"/></span>
               <span id="modal-title-orcid" />
            </h5>
            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&#x00D7;</span>
            </button>
          </div>
          <div class="modal-body" id="orcid-settings-container">
            <div id="orcid-missing-setting-alert" class="alert alert-danger d-none">
              <xsl:value-of select="document('i18n:orcid.settingsModal.missingSettingAlertTest')"/>
            </div>
            <p><xsl:value-of select="document('i18n:orcid.settingsModal.work.introduction')"/></p>
            <form id="orcid-settings-form">
              <div class="form-check">
                <input id="create-first-work-setting" class="form-check-input" type="checkbox" name="createFirstWork"/>
                <label class="form-check-label" for="create-first-work-setting">
                  <xsl:value-of select="document('i18n:orcid.setting.work.createFirstWork.info')"/>
                </label>
              </div>
              <div class="form-check mt-1">
                <input id="always-update-work-setting" class="form-check-input" type="checkbox" name="alwaysUpdateWork"/>
                <label class="form-check-label" for="always-update-work-setting">
                  <xsl:value-of select="document('i18n:orcid.setting.work.alwaysUpdateWork.info')"/>
                </label>
              </div>
              <div class="form-check mt-1">
                <input id="create-duplicate-work-setting" class="form-check-input" type="checkbox" name="createDuplicateWork"/>
                <label class="form-check-label" for="create-duplicate-work-setting">
                  <xsl:value-of select="document('i18n:orcid.setting.work.createDuplicateWork.info')"/>
                </label>
              </div>
              <div class="form-check mt-1">
                <input id="recreate-deleted-work-setting" class="form-check-input" type="checkbox" name="recreateDeletedWork"/>
                <label class="form-check-label" for="recreate-deleted-work-setting">
                  <xsl:value-of select="document('i18n:orcid.setting.work.recreateDeletedWork.info')"/>
                </label>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button id="save-orcid-settings-btn" class="btn btn-primary" type="button">
              <xsl:value-of select="document('i18n:orcid.settings.save')"/>
            </button>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="printOrcidOAuthScopeDescriptionList">
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

  <xsl:template name="printRevokeOrcidButton">
    <xsl:param name="orcid" />
    <button type="button" class="btn btn-danger btn-sm ml-2" title="{document('i18n:orcid.oauth.revoke')}"
      onclick="revokeOrcidOAuth('{$orcid}', '{$WebApplicationBaseURL}servlets/MCRUserServlet?action=show')">
      <xsl:value-of select="document('i18n:orcid.oauth.revoke')"/>
    </button>
  </xsl:template>

  <xsl:template name="printShowOrcidOAuthButton">
    <xsl:param name="scope"/>
    <button type="button" class="btn btn-primary" title="{document('i18n:orcid.integration.popup.tooltip')}"
      onclick="orcidOAuth('{scope}')">
      <img alt="ORCID iD" src="{$WebApplicationBaseURL}images/orcid_icon.svg" class="orcid-icon"/>
      <xsl:value-of select="document('i18n:orcid.oauth.link')"/>
    </button>
  </xsl:template>

  <xsl:template name="printShowOrcidSettingsButton">
    <xsl:param name="orcid" />
    <button type="button" class="btn btn-primary btn-sm" id="openSettingsModalBtn"
      title="{document('i18n:orcid.settings.open')}" data-orcid="{$orcid}">
      <xsl:value-of select="document('i18n:orcid.settings.open')"/>
    </button>
  </xsl:template>

  <xsl:template name="printOrcidSettingsButtonIfRequired">
    <xsl:param name="orcid"/>
    <xsl:variable name="scopeString" select="document(concat('orcidCredential:scope:', $orcid))/string"/>
    <xsl:if test="contains($scopeString, '/activities/update')">
      <xsl:call-template name="printShowOrcidSettingsButton">
        <xsl:with-param name="orcid" select="$orcid"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>

