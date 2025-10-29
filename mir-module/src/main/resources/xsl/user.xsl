<?xml version="1.0" encoding="UTF-8"?>

<!-- XSL to display data of a login user -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:const="xalan://org.mycore.user2.MCRUser2Constants"
                exclude-result-prefixes="xsl xalan i18n acl const mcrxsl"
>

  <xsl:import href="xslImport:userProfileActions"/>
  <xsl:import href="xslImport:userProfileAttributes"/>
  <xsl:include href="MyCoReLayout.xsl" />
  <xsl:include href="resource:xsl/orcid/mir-orcid.xsl"/>
  <xsl:include href="resource:xsl/orcid/mir-orcid-user-ui.xsl"/>

  <xsl:param name="MCR.ORCID2.OAuth.ClientSecret" select="''"/>
  <xsl:variable name="isOrcidEnabled" select="string-length($MCR.ORCID2.OAuth.ClientSecret) &gt; 0"/>

  <xsl:variable name="PageID" select="'show-user'" />

  <xsl:variable name="PageTitle">
    <xsl:call-template name="user-display-name"/>
  </xsl:variable>

  <xsl:param name="step" />
  <xsl:param name="MCR.ORCID2.OAuth.Scope"/>
  <xsl:param name="MCR.ORCID2.BaseURL"/>
  <xsl:param name="MIR.ORCID.InfoURL"/>

  <xsl:param name="MIR.User.ShowSimpleDetailsOnly" select="'false'" />

  <xsl:variable name="uid">
    <xsl:value-of select="/user/@name" />
    <xsl:if test="not ( /user/@realm = 'local' )">
      <xsl:text>@</xsl:text>
      <xsl:value-of select="/user/@realm" />
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="owns" select="document(concat('user:getOwnedUsers:',$uid))/owns" />

  <xsl:template match="user">
    <xsl:variable name="isUserAdmin" select="acl:checkPermission(const:getUserAdminPermission())" />
    <xsl:variable name="fullDetails" select="$isUserAdmin or not($MIR.User.ShowSimpleDetailsOnly='true')" />
    <div class="user-details">
      <div id="buttons" class="btn-group float-end">
        <xsl:apply-templates select="." mode="actions" />
      </div>
      <div class="clearfix" />
      <h2>
        <xsl:call-template name="user-display-name"/>
      </h2>
      <xsl:if test="$step = 'confirmDelete'">
        <div class="section alert alert-danger">
          <p>
            <strong>
              <xsl:value-of select="i18n:translate('component.user2.admin.userDeleteRequest')" />
            </strong>
            <br />
            <xsl:value-of select="i18n:translate('component.user2.admin.userDeleteExplain')" />
            <br />
            <xsl:if test="$owns/user">
              <strong>
                <xsl:value-of select="i18n:translate('component.user2.admin.userDeleteExplainRead1')" />
                <xsl:value-of select="count($owns/user)" />
                <xsl:value-of select="i18n:translate('component.user2.admin.userDeleteExplainRead2')" />
              </strong>
            </xsl:if>
          </p>
          <form class="float-start" method="post" action="MCRUserServlet">
            <input name="action" value="delete" type="hidden" />
            <input name="id" value="{$uid}" type="hidden" />
            <input name="XSL.step" value="deleted" type="hidden" />
            <input value="{i18n:translate('component.user2.button.deleteYes')}" class="btn btn-danger" type="submit" />
          </form>
          <form method="get" action="MCRUserServlet">
            <input name="action" value="show" type="hidden" />
            <input name="id" value="{$uid}" type="hidden" />
            <input value="{i18n:translate('component.user2.button.cancelNo')}" class="btn btn-secondary" type="submit" />
          </form>
        </div>
      </xsl:if>
      <xsl:if test="$step = 'deleted'">
        <div class="section alert alert-success alert-dismissable">
          <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" />
          <p>
            <strong>
              <xsl:value-of select="i18n:translate('component.user2.admin.userDeleteConfirm')" />
            </strong>
          </p>
        </div>
      </xsl:if>
      <xsl:if test="$step = 'changedPassword'">
        <div class="section alert alert-success alert-dismissable">
          <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" />
          <p>
            <strong>
              <xsl:value-of select="i18n:translate('component.user2.admin.passwordChangeConfirm')" />
            </strong>
          </p>
        </div>
      </xsl:if>
      <div class="section" id="sectionlast">
        <div class="table-responsive">
          <table class="user table">
            <xsl:apply-templates select="." mode="user-attributes" />
          </table>
        </div>
        <xsl:if test="$isOrcidEnabled">
          <xsl:call-template name="orcid"/>
          <script type="module" src="{$WebApplicationBaseURL}js/mir/orcid-user.js"/>
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="orcid">
    <article>
      <xsl:choose>
        <xsl:when test="attributes/attribute[starts-with(@name, 'orcid_credential_')]">
          <xsl:variable name="orcidCredentialAttributes"
            select="attributes/attribute[starts-with(@name, 'orcid_credential_')]"/>
          <h3>
            <span class="fas fa-check pe-1" aria-hidden="true"/>
            <xsl:value-of select="document('i18n:mir.orcid.user.integration.status.linked.title')"/>
          </h3>
          <p><xsl:value-of select="document('i18n:mir.orcid.user.integration.status.linked.details')"/></p>
          <xsl:choose>
            <xsl:when test="@realm='orcid.org'">
              <xsl:variable name="orcid" select="substring-after($orcidCredentialAttributes[1]/@name, 'orcid_credential_')"/>
              <xsl:call-template name="render-orcid-settings-button-if-required">
                <xsl:with-param name="orcid" select="$orcid"/>
              </xsl:call-template>
              <br/><br/>
              <xsl:call-template name="render-orcid-settings-modal"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="document('i18n:mir.orcid.user.integration.status.linked.idsHeader')"/>
              <ul class="list-group">
                <xsl:for-each select="$orcidCredentialAttributes/@name">
                  <xsl:variable name="orcid" select="substring-after(., 'orcid_credential_')"/>
                  <li class="list-group-item d-flex align-items-center">
                    <xsl:value-of select="$orcid"/>
                    <xsl:call-template name="render-orcid-settings-button-if-required">
                      <xsl:with-param name="orcid" select="$orcid"/>
                    </xsl:call-template>
                    <xsl:call-template name="render-revoke-orcid-button">
                      <xsl:with-param name="orcid" select="$orcid"/>
                    </xsl:call-template>
                  </li>
                </xsl:for-each>
              </ul>
              <xsl:call-template name="render-default-orcid-settings"/>
              <xsl:call-template name="render-orcid-settings-modal"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <h3>
            <span class="far fa-hand-point-right pe-1" aria-hidden="true"/>
            <xsl:value-of select="document('i18n:mir.orcid.user.integration.status.unlinked.title')"/>
          </h3>
          <p><xsl:value-of select="document('i18n:mir.orcid.user.integration.status.unlinked.details')"/></p>
          <xsl:call-template name="render-orcid-oauth-scope-description-list">
            <xsl:with-param name="scopeString" select="$MCR.ORCID2.OAuth.Scope"/>
          </xsl:call-template>
          <xsl:call-template name="render-show-orcid-oauth-button">
            <xsl:with-param name="scope" select="$MCR.ORCID2.OAuth.Scope"/>
          </xsl:call-template>
          <br/><br/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="string-length($MIR.ORCID.InfoURL) &gt; 0">
        <a href="{$MIR.ORCID.InfoURL}">
          <xsl:value-of select="document('i18n:mir.orcid.user.integration.action.learnMore')"/>
        </a>
      </xsl:if>
    </article>
  </xsl:template>

  <xsl:template name="user-display-name">
    <xsl:choose>
      <xsl:when test="/user/realName">
        <xsl:value-of select="concat(i18n:translate('component.user2.admin.userDisplay'), ' ', /user/realName)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(i18n:translate('component.user2.admin.userDisplay'), ' ', /user/@name)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
