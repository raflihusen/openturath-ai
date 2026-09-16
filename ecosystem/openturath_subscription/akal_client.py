from __future__ import annotations
"""
Akal API Client
================
Client untuk Akal External REST API (goakal.com/service/api/v1).
Digunakan sebagai backup polling dan untuk sinkronisasi manual.

Docs: https://goakal.com/docs/developer
"""

import asyncio
import logging
import os
from typing import Any

import httpx

logger = logging.getLogger(__name__)

AKAL_BASE_URL = "https://goakal.com/service/api/v1"
AKAL_API_KEY = os.getenv("AKAL_API_KEY", "")


class AkalAPIError(Exception):
    """Error dari Akal API."""
    def __init__(self, code: str, message: str, field: str | None = None):
        self.code = code
        self.field = field
        super().__init__(f"[{code}] {message}" + (f" (field: {field})" if field else ""))


class AkalClient:
    """
    Client async untuk Akal External API.

    Contoh penggunaan:
        async with AkalClient() as client:
            txns = await client.get_paid_transactions("clxxx")
    """

    def __init__(self, api_key: str = ""):
        self._api_key = api_key or AKAL_API_KEY
        if not self._api_key:
            raise ValueError(
                "AKAL_API_KEY tidak diset. "
                "Set di .env atau berikan langsung: AkalClient(api_key='ak_...')"
            )
        self._client: httpx.AsyncClient | None = None

    async def __aenter__(self):
        self._client = httpx.AsyncClient(
            base_url=AKAL_BASE_URL,
            headers={
                "X-Api-Key": self._api_key,
                "Content-Type": "application/json",
            },
            timeout=30.0,
        )
        return self

    async def __aexit__(self, *args):
        if self._client:
            await self._client.aclose()
            self._client = None

    def _check_response(self, data: dict) -> dict:
        """Periksa response Akal, raise AkalAPIError jika gagal."""
        if not data.get("success"):
            err = data.get("error", {})
            raise AkalAPIError(
                code=err.get("code", "UNKNOWN"),
                message=err.get("message", "Unknown error"),
                field=err.get("field"),
            )
        return data

    async def _get(self, path: str, params: dict | None = None) -> dict:
        resp = await self._client.get(path, params=params or {})
        resp.raise_for_status()
        return self._check_response(resp.json())

    # ─────────────────────────────────────────────────────
    # SERVICES
    # ─────────────────────────────────────────────────────

    async def list_services(self, page: int = 1, page_size: int = 20) -> dict:
        """List semua service/kelas dalam organisasi."""
        return await self._get("/services", {"page": page, "pageSize": page_size})

    async def get_service(self, service_cuid: str) -> dict:
        """Detail satu service."""
        return await self._get(f"/services/{service_cuid}")

    # ─────────────────────────────────────────────────────
    # TRANSACTIONS
    # ─────────────────────────────────────────────────────

    async def get_transactions(
        self,
        service_cuid: str,
        status: str | None = None,
        price_scheme_title: str | None = None,
        page: int = 1,
        page_size: int = 100,
    ) -> list[dict]:
        """
        List transaksi untuk sebuah service.

        Args:
            service_cuid: CUID service dari Akal
            status: Filter status: PAID | SETTLED | PENDING | EXPIRED | FAILED
            price_scheme_title: Filter berdasarkan nama paket (partial match)
            page: Nomor halaman
            page_size: Jumlah per halaman (max 100)

        Returns:
            List transaksi. Setiap transaksi berisi:
            - payerEmail, payerName, payerPhoneNumber
            - status, paidAt, expiryDate
            - priceSchemeTitle, serviceTitle, serviceCuid
        """
        params: dict[str, Any] = {"page": page, "pageSize": page_size}
        if status:
            params["status"] = status
        if price_scheme_title:
            params["priceSchemeTitle"] = price_scheme_title

        data = await self._get(f"/services/{service_cuid}/transactions", params)
        return data.get("data", [])

    async def get_paid_transactions(self, service_cuid: str) -> list[dict]:
        """Shortcut: ambil semua transaksi PAID untuk satu service."""
        return await self.get_transactions(service_cuid, status="PAID")

    async def get_expired_transactions(self, service_cuid: str) -> list[dict]:
        """Shortcut: ambil semua transaksi EXPIRED untuk satu service."""
        return await self.get_transactions(service_cuid, status="EXPIRED")

    async def get_all_paid_emails(self, service_cuid: str) -> set[str]:
        """
        Ambil semua email yang sudah PAID atau SETTLED untuk satu service,
        yang masa berlakunya belum kedaluwarsa (dihitung dari tanggal bayar + durasi paket).
        """
        import datetime
        paid = await self.get_transactions(service_cuid, status="PAID", page_size=100)
        settled = await self.get_transactions(service_cuid, status="SETTLED", page_size=100)
        all_txns = paid + settled
        
        active_emails = set()
        now = datetime.datetime.now(datetime.timezone.utc)
        
        def determine_duration_months(price_scheme_name: str, service_name: str) -> int:
            price_scheme_lower = price_scheme_name.lower()
            service_name_lower = service_name.lower()
            
            if "tahun" in price_scheme_lower or "1y" in price_scheme_lower or "year" in price_scheme_lower or "annual" in price_scheme_lower:
                return 12
            elif "6 bulan" in price_scheme_lower or "6m" in price_scheme_lower:
                return 6
            elif "bulan" in price_scheme_lower or "1m" in price_scheme_lower or "month" in price_scheme_lower:
                return 1
            else:
                if "bahits" in price_scheme_lower or "bahits" in service_name_lower:
                    return 12
                else:
                    return 1
        
        for t in all_txns:
            email = t.get("payerEmail")
            if not email:
                continue
            email = email.strip().lower()
            
            # Cari waktu mulai langganan (paidAt atau createdAt)
            start_str = t.get("paidAt") or t.get("createdAt")
            if not start_str:
                continue
                
            try:
                start_date = datetime.datetime.fromisoformat(start_str.replace("Z", "+00:00"))
            except Exception:
                start_date = now
                
            price_scheme = t.get("priceSchemeTitle", "")
            service_title = t.get("serviceTitle", "")
            duration_months = determine_duration_months(price_scheme, service_title)
            
            # Hitung masa aktif sebenarnya
            expiry_date = start_date + datetime.timedelta(days=30 * duration_months)
            
            if expiry_date > now:
                active_emails.add(email)
                
        return active_emails

    async def get_all_expired_emails(self, service_cuid: str) -> set[str]:
        """
        Ambil semua email yang sudah EXPIRED atau FAILED untuk satu service.
        Email ini harus kehilangan akses.
        """
        expired = await self.get_transactions(service_cuid, status="EXPIRED", page_size=100)
        failed = await self.get_transactions(service_cuid, status="FAILED", page_size=100)
        all_txns = expired + failed
        return {t["payerEmail"].strip().lower() for t in all_txns if t.get("payerEmail")}
